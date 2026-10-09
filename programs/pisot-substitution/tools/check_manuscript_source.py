#!/usr/bin/env python3
"""Fail closed if a manuscript source or PDF is missing or not what it claims to be.

``manuscripts/MANIFEST`` lists the required files, one per line, and
``manuscripts/TEX_CONTROL_WORDS`` the control words a source may use, one per
line, letters only, sorted: the guard cannot evaluate TeX, so a control word it
has not been told about (a name-based definer from a package, say) fails the
source, as does any control word containing ``@``, whose catcode it does not
model.  Every
listed file must exist; every ``.tex`` in the directory must be valid UTF-8 with
no control bytes other than tab and newline, a ``\\documentclass`` first line,
``\\begin{document}`` before ``\\end{document}``, only allowed control words and
in-order macro parameters before the closing sentinel, and at least MIN_LINES
lines; the directory may hold no subdirectory and no TeX input file (``.sty``,
``.cls``, ...) that a source could load in place of the installed one, and every
package or class loader must name plain names rather than paths;
every ``.pdf`` must carry the ``%PDF-`` header, a ``startxref`` offset that
(the last one before the final ``%%EOF``) that points at a classic ``xref`` table\n(subsections of 20-byte entries, then a ``trailer`` dictionary with ``/Size`` and\n``/Root``) or at a ``/Type /XRef`` stream object whose body matches its direct\n``/Length``, inflates if Flate-encoded, and has a positive multiple of the ``/W``\nrow width, and ``%%EOF``; finally pypdf parses the whole file in strict mode and
every object, including object-stream members, is dereferenced and the page
tree read
within the last 1024 bytes.  Exit status 1 names every failure, so a missing,
byte-mangled or truncated file never passes.

Usage: check_manuscript_source.py [DIR]   (default: manuscripts/)
"""
from __future__ import annotations

import re
import sys
import zlib
from pathlib import Path

MIN_LINES = 500
MAX_XREF_ROWS = 1_000_000  # the repository PDF has 1133 objects; a declaration above this is never inflated
MAX_STREAM_BYTES = 1 << 26  # the largest decoded stream in the repository PDF is 34 KB
ROOT = Path(__file__).resolve().parents[1]


# TeX conditionals that a matching \\fi closes: the primitives of TeX, e-TeX and pdfTeX; the guard
# adds the names a source declares with \\newif.  \\iff (a symbol) and brace-argument macros such
# as \\ifthenelse are not conditionals in this sense.
_TEX_IFS = frozenset("if ifcat ifnum ifdim ifodd ifvmode ifhmode ifmmode ifinner ifvoid ifhbox ifvbox ifx ifeof "
                     "iftrue iffalse ifcase ifdefined ifcsname iffontchar ifincsname ifprimitive ifpdfprimitive "
                     "ifpdfabsnum ifpdfabsdim".split())


# Control words that end the input, read other files, construct control sequences, change how the
# rest of the source is read, or define, alias, prefix or assemble control words at the TeX level
# (definers, register definers, \\font, \\read, expansion control, token registers TeX inserts
# by itself): the guard cannot follow any of them, so one before the closing sentinel (at any
# depth, since a macro body or a skipped branch cannot be told apart) fails.  The LaTeX-level
# definers are handled by the tampering rules in check_tex instead.
_TEX_STOPS = frozenset("endinput csname catcode scantokens lowercase uppercase directlua input include "
                       "InputIfFileExists @input openin stop dump ExplSyntaxOn "
                       "def gdef edef xdef let futurelet chardef mathchardef countdef dimendef skipdef toksdef "
                       "muskipdef font read readline global long outer protected expandafter noexpand unexpanded "
                       "the toks newtoks aftergroup afterassignment everypar everymath everydisplay everyhbox "
                       "everyvbox everycr everyeof everyjob output errhelp".split())

# File suffixes LaTeX loads by name from a source (\\documentclass, \\usepackage and their
# kin): a file with one of these in the manuscripts directory, or in a subdirectory a source
# could name, would shadow the installed one, and the guard does not read it.
_TEX_INPUTS = frozenset(".sty .cls .clo .def .cfg .fd .ltx .dtx .ins".split())
# The control words that load such a file: each must name plain package or class names, so no
# path can reach a file outside the installed tree.
_TEX_LOADERS = frozenset("documentclass usepackage RequirePackage LoadClass RequirePackageWithOptions LoadClassWithOptions".split())

# Mandatory-argument counts of the control words a source may use, so that a call whose
# arguments run out before a sentinel or the end of a brace group is caught: a macro takes its
# undelimited arguments from the tokens that follow it, so a bare \\title before
# \\begin{document} would take the \\begin token as its argument.  A word not listed here has
# an arity the guard does not know and fails when it stands within reach of such a boundary;
# macros a source defines with \\newcommand take the arity of their declaration, and the
# conditionals it declares with \\newif take none.  Primitives that read a number or a
# dimension count as taking none: they cannot take a control word silently.
_TEX_ARITY = {**dict.fromkeys(
    "Delta Lambda Leftrightarrow Longrightarrow Omega Phi Pi Rightarrow S Sigma Theta alpha approx beta bigcup bmod "
    "bottomrule cap cdot cdots chi circ colon cong cup delta deg det dim dots ell emptyset epsilon equiv gamma gcd ge "
    "gtrsim in infty iota item kappa ker lambda langle le lim log maketitle mapsto max mid midrule min mkern mu ne neg "
    "neq nobreakdash noindent notin omega oplus otimes partial perp pi pm prod qquad quad rangle rho setminus sigma sim "
    "small sqcup subset subseteq sum tableofcontents tau times to top toprule varepsilon varphi varsigma wedge "
    "begingroup endgroup relax par newpage clearpage centering hline ldots vdots ddots limits nolimits displaystyle "
    "textstyle scriptstyle scriptscriptstyle lfloor rfloor lceil rceil vert Vert iff else fi or iftrue iffalse ifvmode "
    "ifhmode ifmmode ifinner ifnum ifdim ifcase hfill vfill hrule vrule leq geq subsetneq supset supseteq ni forall "
    "exists nabla int oint iint cap cup bigcap bigvee bigwedge bigoplus bigotimes coprod ast star dagger ddagger "
    "leftarrow rightarrow longleftarrow longrightarrow uparrow downarrow Leftarrow Uparrow Downarrow implies impliedby "
    "zeta eta theta nu xi upsilon phi psi Gamma Xi Upsilon Psi varsigma vartheta varrho varpi aleph hbar imath jmath "
    "wp Re Im prime nexists angle triangle backslash flat natural sharp clubsuit diamondsuit heartsuit spadesuit "
    "sin cos tan cot sec csc arcsin arccos arctan sinh cosh tanh coth exp ln lg arg hom inf sup liminf limsup Pr "
    "diamond bullet amalg uplus sqcap dashv vdash models simeq asymp doteq propto parallel ll gg prec succ preceq "
    "succeq smile frown bowtie lhd rhd unlhd unrhd centerdot ne le ge".split(), 0),
    **dict.fromkeys(
    "arabic author bar begin bibitem bigl bigr boxed check cite date documentclass emph end eqref label mathbb mathbf "
    "mathbin mathcal mathfrak mathrm mathsf not operatorname overline paragraph pmod ref roman section sqrt subsection "
    "subsubsection text textbf textit textsc texttt textup thanks theoremstyle tilde title usepackage v "
    "hat vec dot ddot breve acute grave widehat widetilde underline underbrace overbrace hspace vspace hskip vskip "
    "caption footnote url includegraphics textsuperscript textsubscript mathit mathop mathrel mathord mathpunct "
    "mathopen mathclose left right big Big bigg Bigg bigm Bigm biggm Biggm Bigl Bigr biggl biggr Biggl Biggr "
    "newif newcounter newlength newdimen newcount newskip newbox newmuskip newread newwrite newfam newinsert newlanguage "
    "newsavebox setcounter refstepcounter stepcounter addtocounter "
    "value pageref autoref nameref hyperref inputencoding fontencoding fontfamily fontsize selectfont textcolor "
    "color chapter part appendix addcontentsline phantom hphantom vphantom smash mathstrut ifodd ifdefined ifeof "
    "ifvoid ifhbox ifvbox DeclareGraphicsExtensions graphicspath bibliographystyle bibliography nocite ensuremath "
    "protect".split(), 1),
    **dict.fromkeys("binom frac newcommand newtheorem texorpdfstring renewcommand providecommand DeclareMathOperator DeclareRobustCommand "
                    "setlength addtolength href if ifcat ifx iffontchar tfrac dfrac cfrac overset underset stackrel "
                    "substack".split(), 2),
    **dict.fromkeys("ifthenelse newenvironment renewenvironment".split(), 3)}
# Control symbols (a backslash and one non-letter): the accents take one argument, the rest none.
_TEX_SYMBOL_ARITY = dict.fromkeys("'\"^~=.", 1)
# The definers whose effect on a control word the guard models, by what LaTeX does with a name
# that is already defined: "new" definers leave it (with an error) and define only a fresh
# name, "renew" redefines only a defined one, "always" defines either way.  Any other control
# word of the definer families (a ...command... macro, a Declare... macro or an allocator) has
# an effect the guard does not model and fails the source.
_TEX_DEFINERS = {**dict.fromkeys("newcommand providecommand DeclareMathOperator newlength newsavebox".split(), "new"),
                 "renewcommand": "renew",
                 **dict.fromkeys("DeclareRobustCommand newcount newdimen newskip newmuskip newbox newread newwrite newfam newinsert "
                                 "newlanguage".split(), "always")}


def _units_before(active: str, openers: dict[int, int], end: int, floor: int) -> list[tuple[int, str, str]]:
    """The argument units before ``active[end]`` and after ``floor``, oldest first: a brace group
    (``openers`` maps each closing brace to its opener), a control word, a control symbol or a
    single character, as (start, kind, text).  No cap: the units of an optional argument could
    otherwise exhaust a bounded lookback before the call that takes it."""
    units, j, letter_run_start = [], end, None
    while True:
        while j > floor and active[j - 1] in " \t\n":
            j -= 1
        if j <= floor:
            break
        c = active[j - 1]
        if j - 1 in openers:
            start, kind = openers[j - 1], "group"
            letter_run_start = None
        else:
            if c.isalpha() and letter_run_start is not None and letter_run_start < j:
                k = letter_run_start
            else:
                k = j - 1
                while k > floor and c.isalpha() and active[k - 1].isalpha():
                    k -= 1
                letter_run_start = k if c.isalpha() else None
            slashes = 0
            while k - 1 - slashes >= floor and active[k - 1 - slashes] == "\\":
                slashes += 1
            if slashes % 2:  # an odd run of backslashes ends a control word or symbol
                start, kind = k - 1, "word" if c.isalpha() else "symbol"
                letter_run_start = None
            else:
                start, kind = (k if c.isalpha() else j - 1), "char"
                if c.isalpha() and k != j - 1:  # a plain letter run: emit one unit but reuse its start
                    start = j - 1
                if c.isalpha() and start == k:
                    letter_run_start = None
        units.append((start, kind, active[start:j]))
        j = start
    return units[::-1]


def _unfinished(active: str, openers: dict[int, int], end: int, floor: int, arity) -> tuple[int, str] | None:
    """A control word or symbol among the units before ``active[end]`` whose arguments would reach
    ``end`` (or whose arity the guard does not know), as (position, name); None if every call
    completes before the boundary.  ``arity(name, position)`` gives a word's mandatory-argument
    count at that position, or None.  A * and [...] groups right after the call are optional."""
    units = _units_before(active, openers, end, floor)
    for i, (pos, kind, text) in enumerate(units):
        if kind not in ("word", "symbol"):
            continue
        n = arity(text[1:], pos) if kind == "word" else _TEX_SYMBOL_ARITY.get(text[1:], 0)
        if n is None:
            return pos, text
        k = i + 1 + (i + 1 < len(units) and units[i + 1][2] == "*")
        while k < len(units) and units[k][2] == "[":  # skip an optional argument up to its ]
            k = next((m for m in range(k, len(units)) if units[m][2] == "]"), len(units) - 1) + 1
        if len(units) - k < n:
            return pos, text
    return None


def check_tex(path: Path, allowed: frozenset[str]) -> list[str]:
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as e:
        return [f"{path}: not valid UTF-8 ({e})"]
    problems = []
    bad = sorted({c for c in text if ord(c) < 32 and c not in "\n\t"})
    if bad:
        problems.append(f"{path}: control characters {[hex(ord(c)) for c in bad]}")
    lines = text.splitlines()
    if (caret := text.find("^^")) >= 0:  # TeX's input processor rewrites ^^ notation before any token below is seen;
        problems.append(f"{path}: TeX ^^ notation on line {text.count(chr(10), 0, caret) + 1} cannot be followed")  # the guard does not model it
    first = next((l for l in lines if l.strip()), "")
    if not first.startswith("\\documentclass"):
        problems.append(f"{path}: first line is not \\documentclass")
    # a TeX comment runs from a % preceded by an even run of backslashes (\\ is a control sequence,
    # \% an escaped percent) to the line end; a sentinel counts only as a standalone line of what
    # remains at brace depth zero (braces escaped by an odd run of backslashes do not nest) and
    # outside every conditional (an \\if... word from _TEX_IFS or declared by \\newif, closed by
    # \\fi), because the guard cannot evaluate TeX; so an occurrence inside a macro body, a skipped
    # branch, after \\, or beside other commands does not count.  A conditional token inside a
    # brace group is executed when the group is ordinary text and not when it is a macro body,
    # which the guard cannot tell apart either, so such a token is a problem in itself.  The
    # document must begin before the first end sentinel, since TeX stops at the first.
    active = "\n".join(re.sub(r"(?<!\\)((?:\\\\)*)%.*", r"\1", l) for l in lines)
    braces = [(m.end() - 1, 1 if m.group(1) == "{" else -1) for m in re.finditer(r"(?<!\\)(?:\\\\)*([{}])", active)]
    depth = lambda events, pos: sum(d for i, d in events if i < pos)
    ifs = _TEX_IFS | set(re.findall(r"(?<!\\)(?:\\\\)*\\newif[ \t\n]*\\(if[a-zA-Z]+)", active))
    declared_out = re.sub(r"(?<!\\)((?:\\\\)*)\\newif[ \t\n]*\\if[a-zA-Z]*", lambda m: m.group(1) + " " * (len(m.group()) - len(m.group(1))), active)
    conditionals = [(m.start(1), -1 if m.group(1) == "fi" else 1)
                    for m in re.finditer(r"(?<!\\)(?:\\\\)*\\(if[a-zA-Z]*|fi)(?![a-zA-Z])", declared_out)
                    if m.group(1) == "fi" or m.group(1) in ifs]
    nested = [pos for pos, _ in conditionals if depth(braces, pos) != 0]
    if nested:
        problems.append(f"{path}: a TeX conditional token inside a brace group (line {active.count(chr(10), 0, nested[0]) + 1}) "
                        "cannot be classified as executed or not; keep conditionals at the top level")

    def sentinel(name: str) -> int:
        for m in re.finditer(r"^[ \t]*(\\" + name + r"\{document\})[ \t]*$", active, re.M):
            if depth(braces, m.start()) == 0 and depth(conditionals, m.start()) == 0:
                return m.start(1)
        return -1

    b, e = sentinel("begin"), sentinel("end")
    # a closing brace or \\fi that no opener precedes stops TeX with an error before the document,
    # and a later opener would cancel it in a plain sum: the running depth may never go negative
    for events, what in ((braces, "closing brace"), (conditionals, "\\fi")):
        level = 0
        for pos, d in events:
            if e >= 0 and pos >= e:
                break
            level += d
            if level < 0:
                problems.append(f"{path}: an unmatched {what} on line {active.count(chr(10), 0, pos) + 1} precedes \\end{{document}}")
                break
    # every control word before the closing sentinel must be one the guard has been told about;
    # control symbols (a backslash and one non-letter) define nothing and are exempt.  The scan
    # takes @ as a letter, so a word containing @ (which cannot be listed) fails whichever
    # catcode @ has: as one unknown word, or as a known word the guard would otherwise have
    # cut short
    unknown = [m for m in re.finditer(r"(?<!\\)(?:\\\\)*\\([a-zA-Z@]+)", active) if m.group(1) not in allowed and (e < 0 or m.start(1) < e)]
    if unknown:
        problems.append(f"{path}: \\{unknown[0].group(1)} on line {active.count(chr(10), 0, unknown[0].start()) + 1} is not listed in "
                        "TEX_CONTROL_WORDS; the guard cannot follow a control word it has not been told about")
    # a macro parameter must be #1..#9 inside a brace group, and within one top-level group the
    # parameters must appear in strictly increasing order: a body such as #2#1 would reorder the
    # tokens around a definer in ways the guard cannot follow
    starts, level = [], 0
    for i, d in braces:
        starts += [i] if level == 0 and d == 1 else []
        level += d
    params = [(max((s for s in starts if s < m.start(1)), default=-1), active[m.end(1):m.end(1) + 1], m.start(1))
              for m in re.finditer(r"(?<!\\)(?:\\\\)*(#)", active) if e < 0 or m.start(1) < e]
    order = {}
    for group, digit, pos in params:
        if group < 0 or depth(braces, pos) == 0 or digit not in "123456789" or (group in order and digit <= order[group]):
            problems.append(f"{path}: macro parameter on line {active.count(chr(10), 0, pos) + 1} is outside a body, not #1..#9 or out of "
                            "order; the guard cannot follow it")
            break
        order[group] = digit
    # a package or class loader must name plain names (letters, digits, - and _, comma-separated
    # after an optional [options] group), never a path
    loaders = [m for m in re.finditer(r"(?<!\\)(?:\\\\)*\\(" + "|".join(sorted(_TEX_LOADERS)) + r")(?![a-zA-Z@])"
                                      r"(?![ \t\n]*(?:\[[^\]]*\][ \t\n]*)?\{[ \t\n]*[a-zA-Z0-9_-]+(?:[ \t\n]*,[ \t\n]*[a-zA-Z0-9_-]+)*[ \t\n]*\})", active)
               if e < 0 or m.start() < e]
    if loaders:
        problems.append(f"{path}: \\{loaders[0].group(1)} on line {active.count(chr(10), 0, loaders[0].start()) + 1} does not name plain package or "
                        "class names; a path could load a file the guard does not read")
    # the sentinels must sit inside no other environment: an environment such as comment or verbatim
    # discards or quotes its body, and an environment left open at \\end{document} is an error; so
    # the environment uses up to the closing sentinel must nest properly (at any brace depth, since
    # a macro body cannot be told apart), with nothing open at the opening sentinel and nothing but
    # document open at the closing one
    stack = []
    for m in re.finditer(r"(?<!\\)(?:\\\\)*\\(begin|end)[ \t]*\{([a-zA-Z0-9*]+)\}", active):
        pos = m.end(1) - len(m.group(1)) - 1
        if e >= 0 and pos > e:
            break
        if m.group(1) == "begin":
            stack.append(m.group(2))
        elif not stack or stack.pop() != m.group(2):
            problems.append(f"{path}: \\end{{{m.group(2)}}} on line {active.count(chr(10), 0, pos) + 1} closes no open environment; the guard cannot follow it")
            break
        if (pos == b and stack[:-1]) or (pos == e and stack):
            problems.append(f"{path}: the document sentinel on line {active.count(chr(10), 0, pos) + 1} sits inside the environment "
                            f"{(stack[:-1] or stack)[-1]}, which the guard cannot follow")
            break
    # a macro takes its arguments from the tokens after it, so a call whose arguments run out
    # before a sentinel would take the sentinel's \\begin or \\end as an argument; the same for a
    # call at the end of any brace group, since a macro body's expansion and an argument a body
    # re-emits are followed by whatever comes after the call, and a call at the end of an
    # argument passed as a single token is checked the same way.  Only a definer's target
    # group, {\\name}, holds a bare control word by design.  A macro defined by \\newcommand takes
    # the arity of the latest declaration that executes before the call: one at brace depth zero,
    # outside every conditional and before the closing sentinel (a declaration in a group, a
    # skipped branch or after the document may never run), and earlier in the source than the
    # call; likewise a conditional declared by \\newif, with its ...true and ...false setters, takes
    # none from its declaration on.  Only a declaration LaTeX carries out counts, as _TEX_DEFINERS
    # records for each modelled definer; a definer the guard does not model fails the source.
    unmodelled = [m for m in re.finditer(r"(?<!\\)(?:\\\\)*\\([a-zA-Z]*[cC]ommand[a-zA-Z]*|Declare[a-zA-Z]*|new(?:length|savebox|count|dimen|skip|"
                                         r"muskip|box|read|write|fam|insert|language))(?![a-zA-Z])", active)
                  if m.group(1) not in _TEX_DEFINERS and (e < 0 or m.start() < e)]
    if unmodelled:
        problems.append(f"{path}: \\{unmodelled[0].group(1)} on line {active.count(chr(10), 0, unmodelled[0].start()) + 1} is a definer whose effect "
                        "on control words the guard does not model")
    executable = lambda pos: (e < 0 or pos < e) and depth(braces, pos) == 0 and depth(conditionals, pos) == 0
    declared = [(m.start(), name, 0) for m in re.finditer(r"(?<!\\)(?:\\\\)*\\newif[ \t\n]*\\if([a-zA-Z]+)", active) if executable(m.start())
                for name in ("if" + m.group(1), m.group(1) + "true", m.group(1) + "false")]
    for m in re.finditer(r"(?<!\\)(?:\\\\)*\\(" + "|".join(sorted(_TEX_DEFINERS)) + r")(?![a-zA-Z])\*?[ \t\n]*\{?[ \t\n]*\\([a-zA-Z]+)[ \t\n]*\}?[ \t\n]*"
                         r"(?:\[(\d)\](?:[ \t\n]*\[([^\]]*)\])?)?", active):  # [n][default] makes the first of n arguments optional
        kind, name = _TEX_DEFINERS[m.group(1)], m.group(2)
        prior = any(nm == name for _, nm, _ in declared)
        # Arity metadata is not proof that a package-independent definition exists:
        # e.g. \\mathbb has known arity but is absent with the article class alone.
        # A state-dependent definer aimed at such a name must therefore fail closed.
        defined = True if prior else None if name in _TEX_ARITY else False
        if executable(m.start()):
            if kind == "always" or (defined is not None and defined == (kind == "renew")):
                declared.append((m.start(), name, int(m.group(3) or 0) - (m.group(4) is not None) if m.group(1).endswith("ommand") else 0))
            elif defined is None:
                problems.append(f"{path}: \\{m.group(1)} targets \\{name} on line {active.count(chr(10), 0, m.start()) + 1}, "
                                "whose current definition state the guard cannot determine")
    declared.sort()
    arity = lambda name, pos: next((n for d, nm, n in reversed(declared) if nm == name and d < pos), _TEX_ARITY.get(name))
    openers, open_stack = {}, []
    for i, d in braces:
        open_stack.append(i) if d > 0 else (openers.__setitem__(i, open_stack.pop()) if open_stack else None)
    targets = {m.start(1) for m in re.finditer(
        r"(?<!\\)(?:\\\\)*\\(?:[a-zA-Z]*[cC]ommand[a-zA-Z]*|Declare[a-zA-Z]*|new(?:length|counter|savebox|count|dimen|skip|box|toks|read|write))"
        r"\*?[ \t\n]*(\{)[ \t\n]*\\[a-zA-Z]+[ \t\n]*\}", active)}
    boundaries = [(c, o) for c, o in openers.items() if (e < 0 or c < e) and o not in targets] + [(p, 0) for p in (b, e) if p >= 0]
    for end, floor in sorted(boundaries):
        if (unfinished := _unfinished(active, openers, end, floor, arity)) is not None:
            problems.append(f"{path}: {unfinished[1]} on line {active.count(chr(10), 0, unfinished[0]) + 1} has fewer arguments than it takes before "
                            f"the {'document sentinel' if end in (b, e) else 'end of its brace group'} on line {active.count(chr(10), 0, end) + 1}, "
                            "or an arity the guard does not know; it could take what follows as an argument")
            break
    # every other \\begin{document} or \\end{document} before the closing sentinel, in a macro body
    # or beside other text, could be executed by a macro or a group and end or restart the document
    # in ways the guard cannot follow
    stray = [m for m in re.finditer(r"(?<!\\)(?:\\\\)*(\\(begin|end)[ \t]*\{document\})", active)
             if m.start(1) != (b if m.group(2) == "begin" else e) and (e < 0 or m.start(1) < e)]
    if stray:
        problems.append(f"{path}: \\{stray[0].group(2)}{{document}} on line {active.count(chr(10), 0, stray[0].start()) + 1} is not the standalone "
                        "sentinel; a macro or group could execute it, which the guard cannot follow")
    # the sentinels mean what LaTeX defines only while \\begin, \\end and the document environment keep
    # their definitions: \\begin and \\end may occur only as environment uses followed by {name} with a
    # plain name (a name assembled from a macro parameter could spell document), never as the
    # target of a definer (\\def and its variants, \\let, \\futurelet, a prefix such as \\global, or any
    # ...command... macro), the internal \\document and \\enddocument may not occur, and no
    # environment-defining command (a ...environment... or ...theorem... macro, since \\newtheorem
    # defines an environment too) may target document, begin or end, and must name its target as a
    # literal plain name right there, since LaTeX expands the argument into the environment's
    # control-sequence names and a macro could expand to document.  TeX skips the white space after a control
    # word, a line ending included (a comment ends a line), so a definer, \\newif and an argument
    # may be separated from what follows by line endings as well as by spaces; a LaTeX definer may
    # carry a * before its target; a ...namedef... or ...namelet... macro defines the control
    # word spelled by its brace argument without a \\csname in the source; a Declare... macro or a
    # register allocator may target a control word too; and a ...command... macro must name its
    # target as a control word right there, followed by its body or argument count, since a target
    # reaching it through a macro parameter or another macro's body (a wrapper around the definer)
    # cannot be followed
    tampering = (re.search(r"(?<!\\)(?:\\\\)*\\(begin|end)(?![a-zA-Z@])(?![ \t]*\{[a-zA-Z0-9*]+\})", active)
                 or re.search(r"(?<!\\)(?:\\\\)*\\([gex]?def|let|futurelet|global|long|outer|protected|[a-zA-Z@]*[cC]ommand[a-zA-Z@]*"
                              r"|Declare[a-zA-Z@]*|new(?:count|dimen|skip|muskip|box|read|write|language|insert|fam|marks|attribute))"
                              r"[ \t\n]*\*?[ \t\n]*\{?[ \t\n]*\\(?:begin|end|document|enddocument)(?![a-zA-Z@])", active)
                 or re.search(r"(?<!\\)(?:\\\\)*\\([a-zA-Z@]*[cC]ommand[a-zA-Z@]*)[ \t\n]*\*?[ \t\n]*(?![ \t\n*])"
                              r"(?!(?:\{[ \t\n]*\\[a-zA-Z@]+[ \t\n]*\}|\\[a-zA-Z@]+)[ \t\n]*[{\[])", active)
                 or re.search(r"(?<!\\)(?:\\\\)*\\([a-zA-Z@]*name(?:def|let)[a-zA-Z@]*)[ \t\n]*\{[ \t\n]*(?:begin|end|document|enddocument)[ \t\n]*\}", active)
                 or re.search(r"(?<!\\)(?:\\\\)*\\(document|enddocument)(?![a-zA-Z@])", active)
                 or re.search(r"(?<!\\)(?:\\\\)*\\([a-zA-Z@]*(?:[eE]nvironment|[tT]heorem)[a-zA-Z@]*)(?![a-zA-Z@])[ \t\n]*\*?[ \t\n]*"
                              r"(?![ \t\n*])(?!\{(?!(?:document|begin|end|enddocument)\})[a-zA-Z0-9*]+\})", active))
    if tampering:
        problems.append(f"{path}: \\{tampering.group(1)} on line {active.count(chr(10), 0, tampering.start()) + 1} "
                        "can change what the document sentinels mean")
    stop = re.search(r"(?<!\\)(?:\\\\)*\\(" + "|".join(sorted(_TEX_STOPS)) + r")(?![a-zA-Z@])", active)
    if stop and (e < 0 or stop.start() < e):
        problems.append(f"{path}: \\{stop.group(1)} on line {active.count(chr(10), 0, stop.start()) + 1} precedes "
                        "\\end{document}; the guard cannot follow it")
    if b < 0 or e < b:
        problems.append(f"{path}: missing or misordered \\begin{{document}} / \\end{{document}} as standalone uncommented top-level lines outside conditionals")
    if len(lines) < MIN_LINES:
        problems.append(f"{path}: only {len(lines)} lines (< {MIN_LINES})")
    return problems


def _dict_at(buf: bytes, i: int) -> bytes | None:
    """The dictionary starting at ``buf[i:i+2] == b'<<'``, delimiters included, parsed as
    a sequence of name keys each followed by one complete direct value; None otherwise."""
    end = _dict_end(buf, i)
    return None if end is None else buf[i:end]


def _trailer_keys(items: dict[bytes, bytes], what: str) -> str | tuple[int, tuple[int, int], int | None, int | None]:
    """``(/Size, /Root as (number, generation), /Prev or None, /XRefStm or None)`` read from
    a trailer or cross-reference stream dictionary's top-level items; a present ``/Prev``
    or ``/XRefStm`` must be a whole integer."""
    size = _int_value(items.get(b"Size", b""))
    root = re.fullmatch(rb"(\d+)[\x00\t\n\x0c\r ]+(\d+)[\x00\t\n\x0c\r ]+R", items.get(b"Root", b""))
    if size is None or not root:
        return f"{what} lacks /Size or /Root"
    links = [_int_value(items[k]) if k in items else None for k in (b"Prev", b"XRefStm")]
    if any(k in items and v is None for k, v in zip((b"Prev", b"XRefStm"), links)):
        return f"{what} /Prev or /XRefStm is not a whole integer"
    return size, (int(root.group(1)), int(root.group(2))), links[0], links[1]


Entry = tuple[int, int, int, bool]
"""``(kind, field, generation, classic)``: kind 0 is free (field = next free object number),
kind 1 in use (field = byte offset), kind 2 compressed (field = object stream number,
generation slot = index); ``classic`` records whether the entry came from a classic table,
whose free entries must be on the free list, rather than from a cross-reference stream."""


Section = tuple[dict[int, Entry], int, int | None, int | None, int, tuple[int, int]]
"""``(entries by object number, trailer /Size, /Prev offset or None, /XRefStm offset or None,
offset just past the section, /Root as (object number, generation))``."""


# PDF white space is exactly NUL, tab, line feed, form feed, carriage return and space (ISO 32000-1,
# 7.2.2): the regex class for white space would admit vertical tab and omit NUL, and bytes.strip()/split() likewise, so
# every pattern and strip below spells the six bytes out.
_WSB = b"\x00\t\n\x0c\r "
_DELIM = rb"[\x00\t\n\x0c\r /\[\]<>(){}%]"
_NAME = rb"/((?:[^\x00\t\n\x0c\r /\[\]<>(){}%#]|#[0-9A-Fa-f]{2})*)(?=" + _DELIM + rb"|$)"


def _unescape(name: bytes) -> bytes:
    return re.sub(rb"#([0-9A-Fa-f]{2})", lambda m: bytes([int(m.group(1), 16)]), name)


def _name_value(value: bytes) -> bytes | None:
    """The decoded name if ``value`` is exactly one name token, else None."""
    m = re.fullmatch(_NAME, value)
    return _unescape(m.group(1)) if m else None


def _int_value(value: bytes) -> int | None:
    """The integer if ``value`` is exactly one whole nonnegative integer, else None."""
    return int(value) if re.fullmatch(rb"\d+", value) else None


def _names_of(value: bytes) -> list[bytes] | None:
    """``value`` as a list of decoded names: one name, or an array of names; else None."""
    if not value.startswith(b"["):
        single = _name_value(value)
        return [single] if single is not None else None
    names, pos = [], 1
    while True:
        pos += len(value[pos:]) - len(value[pos:].lstrip(_WSB))
        if value[pos:pos + 1] == b"]":
            return names if pos + 1 == len(value) else None
        m = re.match(_NAME, value[pos:])
        if not m:
            return None
        names.append(_unescape(m.group(1)))
        pos += m.end()


def _filter_names(d: bytes) -> list[bytes] | None:
    """The top-level ``/Filter`` value of dictionary bytes ``d`` as a list of names: ``[]``
    without the key, ``None`` when the dictionary or the value does not parse."""
    items = _dict_items(d, 0)
    if items is None:
        return None
    return _names_of(items[b"Filter"]) if b"Filter" in items else []


def _classic_table(raw: bytes, off: int) -> str | Section:
    """The classic ``xref`` table at ``raw[off:]``: a problem, or its section."""
    at = raw[off:]
    m = re.match(rb"xref[ \t]*(?:\r\n|\r|\n)", at)
    if not m:
        return "malformed xref keyword"
    pos, entries, ranges, table = m.end(), 0, [], {}
    while True:
        sub = re.match(rb"(\d+)[ \t]+(\d+)[ \t]*(?:\r\n|\r|\n)", at[pos:pos + 64])
        if not sub:
            break
        pos, start, count = pos + sub.end(), int(sub.group(1)), int(sub.group(2))
        if count == 0:
            return f"empty xref subsection at object {start}"
        if any(start < s0 + c0 and s0 < start + count for s0, c0 in ranges):
            return f"xref subsection at object {start} overlaps an earlier subsection"
        ranges.append((start, count))
        block = at[pos:pos + 20 * count]
        if len(block) < 20 * count:
            return "truncated xref subsection"
        for k in range(count):
            e = re.fullmatch(rb"(\d{10}) (\d{5}) ([nf])(?: \r| \n|\r\n)", block[20 * k:20 * k + 20])
            if not e:
                return f"malformed xref entry {entries + k}"
            num, field, gen = start + k, int(e.group(1)), int(e.group(2))
            if gen > 65535:
                return f"xref entry for object {num} has generation {gen} > 65535"
            if e.group(3) == b"n":
                # an in-use entry must point at the header of its own object
                if field >= len(raw) or not re.match(rb"%d[\x00\t\n\x0c\r ]+%d[\x00\t\n\x0c\r ]+obj(?=[\x00\t\n\x0c\r /\[\]<>(){}%%]|$)" % (num, gen), raw[field:field + 40]):
                    return f"xref entry for object {num} does not point at '{num} {gen} obj'"
            table[num] = (0 if e.group(3) == b"f" else 1, field, gen, True)
        pos, entries = pos + 20 * count, entries + count
    if entries == 0:
        return "xref table has no entries"
    t = re.match(rb"trailer[\x00\t\n\x0c\r ]*", at[pos:pos + 32])
    if not t:
        return "xref table not followed by trailer"
    parsed = _dict_parse(at, pos + t.end())
    if parsed is None:
        return "trailer has no dictionary"
    keys = _trailer_keys(parsed[0], "trailer dictionary")
    if isinstance(keys, str):
        return keys
    size, root, prev, xrefstm = keys
    if any(st + c > size for st, c in ranges):
        return f"xref subsection exceeds the trailer /Size {size}"
    stray = [n for n, (k, f, *_) in table.items() if k == 0 and f >= size]
    if stray:
        return f"free entry for object {stray[0]} points at object {table[stray[0]][1]} beyond /Size"
    return table, size, prev, xrefstm, off + parsed[1], root


def _unpredict(payload: bytes, row: int, bpp: int = 1) -> bytes | None:
    """Undo PNG row prediction (filter byte per row, ``bpp`` bytes per pixel); None on an unknown filter."""
    width, prev, out = row - 1, bytes(row - 1), []
    for i in range(0, len(payload), row):
        f, line = payload[i], bytearray(payload[i + 1:i + row])
        for j in range(width):
            a = line[j - bpp] if j >= bpp else 0
            b, c = prev[j], (prev[j - bpp] if j >= bpp else 0)
            if f == 0:
                pred = 0
            elif f == 1:
                pred = a
            elif f == 2:
                pred = b
            elif f == 3:
                pred = (a + b) // 2
            elif f == 4:
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                pred = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
            else:
                return None
            line[j] = (line[j] + pred) & 0xFF
        prev = bytes(line)
        out.append(prev)
    return b"".join(out)


def _xref_rows(raw: bytes, rows: bytes, widths: list[int], numbers: list[int], size: int) -> str | dict[int, Entry]:
    """Decode each row per ``/W`` and dereference in-use entries; the entries if all agree."""
    w0, w1, w2 = widths
    stride, table = sum(widths), {}
    for i, num in enumerate(numbers):
        r = rows[i * stride:(i + 1) * stride]
        kind = int.from_bytes(r[:w0], "big") if w0 else 1
        f2 = int.from_bytes(r[w0:w0 + w1], "big")
        f3 = int.from_bytes(r[w0 + w1:], "big")
        if kind in (0, 1) and f3 > 65535:
            return f"cross-reference stream entry for object {num} has generation {f3} > 65535"
        if kind == 0:
            if f2 >= size:
                return f"cross-reference stream free entry for object {num} points at object {f2} beyond /Size"
        elif kind == 1:
            if f2 >= len(raw) or not re.match(rb"%d[\x00\t\n\x0c\r ]+%d[\x00\t\n\x0c\r ]+obj(?=[\x00\t\n\x0c\r /\[\]<>(){}%%]|$)" % (num, f3), raw[f2:f2 + 40]):
                return f"cross-reference stream entry for object {num} does not point at '{num} {f3} obj'"
        elif kind == 2:
            if f2 >= size:
                return f"cross-reference stream entry for object {num} names object stream {f2} beyond /Size"
        else:
            return f"cross-reference stream entry for object {num} has unknown type {kind}"
        table[num] = (kind, f2, f3, False)
    return table


def _xref_stream(raw: bytes, off: int) -> str | Section:
    """The cross-reference stream object at ``raw[off:]``: a problem, or its section
    (type-0 rows included).  Every key is read from the dictionary's top-level items."""
    at = raw[off:]
    m = re.match(rb"(\d+)[\x00\t\n\x0c\r ]+(\d+)[\x00\t\n\x0c\r ]+obj[\x00\t\n\x0c\r ]*", at)
    if not m:
        return "not an object"
    num, gen = int(m.group(1)), int(m.group(2))
    parsed = _dict_parse(at, m.end())
    if parsed is None:
        return "object has no dictionary"
    items, dend = parsed
    if _name_value(items.get(b"Type", b"")) != b"XRef":
        return "object is not a cross-reference stream"
    keys = _trailer_keys(items, "cross-reference stream")
    if isinstance(keys, str):
        return keys
    size, root, prev, _ = keys
    w = re.fullmatch(rb"\[[\x00\t\n\x0c\r ]*((?:\d+[\x00\t\n\x0c\r ]*)+)\]", items.get(b"W", b""))
    if not w:
        return "cross-reference stream lacks /W"
    widths = [int(x) for x in re.findall(rb"\d+", w.group(1))]
    if len(widths) != 3:
        return f"cross-reference stream /W must have exactly three fields, has {len(widths)}"
    row, parms = sum(widths), None
    if b"DecodeParms" in items:
        parms = _parms(items[b"DecodeParms"])
        if isinstance(parms, str):
            return f"cross-reference stream {parms}"
        if parms[0] != 1:  # predictor 1 predicts nothing, so its geometry never changes the /W row width
            if _row_width(1, *parms[1:]) != row:
                return f"cross-reference stream predictor geometry gives rows of {_row_width(1, *parms[1:])} bytes but /W gives {row}"
            row = _row_width(*parms)
    if row == 0:
        return "cross-reference stream has zero row width"
    if b"Length" not in items:
        return "cross-reference stream lacks /Length"
    n = _int_value(items[b"Length"])
    if n is None:
        if re.fullmatch(rb"\d+[\x00\t\n\x0c\r ]+\d+[\x00\t\n\x0c\r ]+R", items[b"Length"]):
            return "cross-reference stream /Length is an indirect reference, not a direct integer"
        return "cross-reference stream lacks /Length"
    if b"Index" in items:
        index = re.fullmatch(rb"\[[\x00\t\n\x0c\r ]*((?:\d+[\x00\t\n\x0c\r ]*)*)\]", items[b"Index"])
        values = [int(x) for x in re.findall(rb"\d+", index.group(1))] if index else []
        if not values or len(values) % 2:
            return "cross-reference stream /Index is not an array of start/count pairs"
        pairs = list(zip(values[::2], values[1::2]))
        if any(c <= 0 or st + c > size for st, c in pairs):
            return "cross-reference stream /Index range is empty or exceeds /Size"
        if any(s2 < s1 + c1 for (s1, c1), (s2, _) in zip(pairs, pairs[1:])):
            return "cross-reference stream /Index ranges overlap or are not in increasing order"
    else:
        pairs = [(0, size)]
    expected_rows = sum(c for _, c in pairs)  # object numbers are materialized only once the payload agrees
    if expected_rows > MAX_XREF_ROWS:
        return f"cross-reference stream declares {expected_rows} rows, above the ceiling of {MAX_XREF_ROWS}"
    if expected_rows * row > MAX_STREAM_BYTES:
        return f"cross-reference stream declares {expected_rows * row} decoded bytes, above the ceiling of {MAX_STREAM_BYTES}"
    body = re.match(rb"[\x00\t\n\x0c\r ]*stream(?:\r\n|\n)", at[dend:dend + 16])
    if not body:
        return "cross-reference stream has no stream body"
    data_start = dend + body.end()
    data = at[data_start:data_start + n]
    tail = re.match(rb"(?:\r\n|\r|\n)endstream[\x00\t\n\x0c\r ]*endobj(?=[\x00\t\n\x0c\r /\[\]<>(){}%]|$)", at[data_start + n:data_start + n + 32])
    if len(data) < n or not tail:
        return "cross-reference stream body does not match /Length or is not closed by endstream and endobj"
    filters = _names_of(items[b"Filter"]) if b"Filter" in items else []
    if filters is None:
        return "cross-reference stream /Filter is not a name or an array of names"
    if filters and filters != [b"FlateDecode"]:
        return f"unsupported cross-reference stream filter chain {[f.decode(errors='replace') for f in filters]}"
    if filters:
        inflater = zlib.decompressobj()
        try:
            payload = inflater.decompress(data, expected_rows * row + 1)  # never inflate past the declared size
        except zlib.error as e:
            return f"cross-reference stream payload does not inflate ({e})"
        if not inflater.eof or inflater.unconsumed_tail or inflater.unused_data:
            return "cross-reference stream payload inflates past the declared row count or is not a complete deflate member"
    else:
        payload = data
    if len(payload) == 0 or len(payload) % row != 0:
        return f"cross-reference stream payload of {len(payload)} bytes is not a positive multiple of the row width {row}"
    rows = len(payload) // row
    if rows != expected_rows:
        return f"cross-reference stream has {rows} rows but declares {expected_rows} (/Index or /Size)"
    numbers = [st + k for st, c in pairs for k in range(c)]
    if parms is not None:
        payload = _undo_predictor(payload, *parms)
        if isinstance(payload, str):
            return f"cross-reference stream {payload}"
    table = _xref_rows(raw, payload, widths, numbers, size)
    if isinstance(table, str):
        return table
    if table.get(num, (None,))[:3] != (1, off, gen):  # the stream is an object of its own revision, so its section must list it
        return f"cross-reference stream object {num} {gen} at offset {off} is not listed by its own section as an in-use entry at that offset, so /Size and the entries do not account for it"
    return (table, size, prev, None, off + data_start + n + tail.end(), root)


def _free_list(table: dict[int, Entry], classic: bool) -> str | None:
    """Object 0 is free (with generation 65535 when its entry comes from a classic table)
    and heads a chain of free entries that returns to object 0.  ``table`` is the effective
    table at one section of the chain: at a classic section every classic free entry must
    be on the chain; a stream type-0 entry (the free list of a cross-reference stream is
    optional) may be off the chain if it points at 0 or at another free entry, but never
    at an object in use."""
    head = table.get(0)
    if head is None or head[0] != 0:
        return "object 0 is not a free entry"
    if head[3] and head[2] != 65535:
        return f"object 0 in a classic table has generation {head[2]}, not 65535"
    free, walked, n = {k for k, v in table.items() if v[0] == 0}, [0], head[1]
    while n != 0:
        if n not in free or n in walked:
            return f"free list reaches object {n}, which is not an unvisited free entry"
        walked.append(n)
        n = table[n][1]
    stray = sorted(n for n in free - set(walked) if (classic and table[n][3]) or table[n][1] not in free | {0})
    return f"free entries {stray} are not on the free list" if stray else None


def _section_at(raw: bytes, off: int, seen: list[int]) -> str | Section:
    """Parse the section at ``off``, which must lie in the file and not have been visited.
    Its in-use entries must point before the section itself (a cross-reference stream may
    point at its own object): objects precede the section that lists them, so a target in
    the section's own trailer region or in a later incremental update is bogus."""
    if off >= len(raw):
        return f"cross-reference offset {off} beyond end of file ({len(raw)} bytes)"
    if off in seen:
        return f"cross-reference chain revisits offset {off}"
    seen.append(off)
    at = raw[off:]
    if at.startswith(b"xref"):
        section = _classic_table(raw, off)
    elif re.match(rb"\d+[\x00\t\n\x0c\r ]+\d+[\x00\t\n\x0c\r ]+obj(?=[\x00\t\n\x0c\r /\[\]<>(){}%]|$)", at[:32]):
        section = _xref_stream(raw, off)
    else:
        section = "offset does not point at an xref table or object"
    if isinstance(section, str):
        return f"at cross-reference offset {off}: {section}"
    limit = off + (0 if at.startswith(b"xref") else 1)
    late = [(n, f) for n, (k, f, *_) in section[0].items() if k == 1 and f >= limit]
    if late:
        return f"entry for object {late[0][0]} points at offset {late[0][1]}, not before its cross-reference section at {off}"
    for n, (k, f, *_) in section[0].items():  # every listed object closes before the section; the stream itself was parsed whole
        if k == 1 and f != off and isinstance(problem := _whole_object(raw[f:off], n), str):
            return f"{problem} within the bytes before its cross-reference section at {off}"
    return section


def _untiff(out: bytes, width: int, colors: int) -> bytes:
    """Undo TIFF predictor 2 (horizontal differencing, 8 bits per component) row by row."""
    rows = []
    for i in range(0, len(out), width):
        row = bytearray(out[i:i + width])
        for j in range(colors, width):
            row[j] = (row[j] + row[j - colors]) & 0xFF
        rows.append(bytes(row))
    return b"".join(rows)


def _parms(value: bytes) -> tuple[int, int, int, int] | str:
    """``(/Predictor, /Columns, /Colors, /BitsPerComponent)`` of a direct ``/DecodeParms``
    dictionary (or one-element array of one) whose present fields are whole nonnegative
    integers, ``/Predictor`` 1, 2 or 10-15 with positive geometry, TIFF prediction at 8 bits
    per component only; or a problem."""
    if value.startswith(b"["):  # a one-element array holding the dictionary
        inner = re.fullmatch(rb"\[[\x00\t\n\x0c\r ]*(<<.*>>)[\x00\t\n\x0c\r ]*\]", value, re.S)
        value = inner.group(1) if inner else b""
    parms = _dict_items(value, 0)
    if parms is None or _dict_end(value, 0) != len(value):
        return "/DecodeParms is not a direct dictionary"

    def field(name: bytes, default: int) -> int | None:
        return default if name not in parms else _int_value(parms[name])  # present but malformed -> None

    pred, cols, colors, bpc = (field(n, v) for n, v in ((b"Predictor", 1), (b"Columns", 1), (b"Colors", 1), (b"BitsPerComponent", 8)))
    if None in (pred, cols, colors, bpc):
        return "malformed predictor parameter value"
    if pred not in (1, 2, *range(10, 16)):
        return f"unsupported /Predictor {pred}"
    if cols < 1 or colors < 1 or bpc not in (1, 2, 4, 8, 16):
        return "invalid predictor geometry"
    if pred == 2 and bpc != 8:
        return "TIFF prediction is supported for 8 bits per component only"
    return pred, cols, colors, bpc


def _row_width(pred: int, cols: int, colors: int, bpc: int) -> int:
    """Bytes per predicted row: the packed samples, plus the filter byte of a PNG row."""
    return (cols * colors * bpc + 7) // 8 + (pred >= 10)


def _undo_predictor(out: bytes, pred: int, cols: int, colors: int, bpc: int) -> bytes | str:
    """``out`` with predictor ``pred`` undone over rows of the declared geometry (PNG filters
    predicting from the previous pixel of ``ceil(colors * bpc / 8)`` bytes), or a problem."""
    if pred == 1:
        return out
    row = _row_width(pred, cols, colors, bpc)
    if len(out) % row:
        return f"decoded length {len(out)} is not a multiple of the predicted row width {row}"
    if pred >= 10:
        decoded = _unpredict(out, row, (colors * bpc + 7) // 8)
        return "unknown PNG row filter" if decoded is None else decoded
    return _untiff(out, row, colors)


def _unfilter(d: bytes, out: bytes) -> bytes | str:
    """The inflated bytes ``out`` of a Flate stream with dictionary ``d`` after undoing the
    predictor its ``/DecodeParms`` declares (validated by ``_parms``), or a problem."""
    items = _dict_items(d, 0)
    if items is None or b"DecodeParms" not in items:
        return out
    parms = _parms(items[b"DecodeParms"])
    return parms if isinstance(parms, str) else _undo_predictor(out, *parms)


_TOKEN = rb"(?:/(?:[^\x00\t\n\x0c\r /\[\]<>(){}%#]|#[0-9A-Fa-f]{2})*|[+-]?(?:\d+\.?\d*|\.\d+)|true|false|null)(?=" + _DELIM + rb"|$)"


def _dict_parse(buf: bytes, i: int) -> tuple[dict[bytes, bytes], int] | None:
    """The dictionary at ``buf[i:]`` (``<<``, name keys each followed by one complete
    direct value, ``>>``) as ``(top-level items: decoded key -> raw value bytes, index just
    past it)``; None if the bytes are not that."""
    if not buf.startswith(b"<<", i):
        return None
    items, j = {}, i + 2
    while True:
        j += len(buf[j:]) - len(buf[j:].lstrip(_WSB))
        if buf.startswith(b">>", j):
            return items, j + 2
        key = re.match(_NAME, buf[j:])
        if not key:
            return None
        start = j + key.end()
        if (j := _object_end(buf, start)) is None or _unescape(key.group(1)) in items:  # a repeated key is malformed
            return None
        items[_unescape(key.group(1))] = buf[start:j].strip(_WSB)


def _dict_end(buf: bytes, i: int) -> int | None:
    parsed = _dict_parse(buf, i)
    return None if parsed is None else parsed[1]


def _dict_items(buf: bytes, i: int) -> dict[bytes, bytes] | None:
    """Top-level items of the dictionary at ``buf[i:]`` (after leading whitespace), or None."""
    i += len(buf[i:]) - len(buf[i:].lstrip(_WSB))
    parsed = _dict_parse(buf, i)
    return None if parsed is None else parsed[0]


def _object_end(buf: bytes, i: int) -> int | None:
    """The index just past one complete direct object (dictionary, array, string, name,
    number, boolean, null, or indirect reference) starting at or after ``i``; None if the
    bytes there are not one."""
    i += len(buf[i:]) - len(buf[i:].lstrip(_WSB))
    if buf.startswith(b"<<", i):
        return _dict_end(buf, i)
    if buf.startswith(b"<", i):
        m = re.match(rb"<[0-9A-Fa-f\x00\t\n\x0c\r ]*>", buf[i:])
        return i + m.end() if m else None
    if buf.startswith(b"(", i):
        depth, j = 0, i
        while j < len(buf):
            ch = buf[j:j + 1]
            if ch == b"\\":
                j += 2
                continue
            depth, j = depth + (ch == b"(") - (ch == b")"), j + 1
            if depth == 0:
                return j
        return None
    if buf.startswith(b"[", i):
        j = i + 1
        while True:
            j += len(buf[j:]) - len(buf[j:].lstrip(_WSB))
            if buf.startswith(b"]", j):
                return j + 1
            if (j := _object_end(buf, j)) is None:
                return None
    m = re.match(_TOKEN, buf[i:])
    if not m:
        return None
    ref = re.match(rb"[\x00\t\n\x0c\r ]+\d+[\x00\t\n\x0c\r ]+R(?=" + _DELIM + rb"|$)", buf[i + m.end():]) if re.fullmatch(rb"\d+", m.group(0)) else None
    return i + m.end() + (ref.end() if ref else 0)


def _whole_object(at: bytes, num: int) -> str | tuple[int, bytes | None, bytes | None]:
    """``at`` must begin with one complete indirect object ``num``: its header, one direct
    object and ``endobj``, or a dictionary and a stream of its direct ``/Length`` closed by
    ``endstream`` and ``endobj``.  ``(end offset, dictionary, stream data)`` (None where
    absent), or a problem.  Nothing past the end of ``at`` is consulted, so the caller
    bounds the parse."""
    head = re.match(rb"\d+[\x00\t\n\x0c\r ]+\d+[\x00\t\n\x0c\r ]+obj[\x00\t\n\x0c\r ]*", at)
    end = _object_end(at, head.end()) if head else None
    if end is None:
        return f"object {num} is not one complete object"
    body = re.match(rb"[\x00\t\n\x0c\r ]*stream(?:\r\n|\n)", at[end:end + 16]) if at.startswith(b"<<", head.end()) else None
    if not body:
        closed = re.match(rb"[\x00\t\n\x0c\r ]*endobj(?=[\x00\t\n\x0c\r /\[\]<>(){}%]|$)", at[end:end + 16])
        return (end + closed.end(), None, None) if closed else f"object {num} is not one complete object closed by endobj"
    d = at[head.end():end]
    length = _int_value(_dict_items(d, 0).get(b"Length", b""))
    if length is None:
        return f"stream object {num} lacks a direct /Length"
    start = end + body.end()
    data = at[start:start + length]
    tail = re.match(rb"(?:\r\n|\r|\n)endstream[\x00\t\n\x0c\r ]*endobj(?=[\x00\t\n\x0c\r /\[\]<>(){}%]|$)", at[start + length:start + length + 32])
    if len(data) < length or not tail:
        return f"stream object {num} does not match its /Length or is not closed by endstream and endobj"
    return start + length + tail.end(), d, data


def _covered(raw: bytes, start: int, end: int, entries: dict[int, Entry]) -> str | None:
    """The revision body ``raw[start:end]`` must consist exactly of the in-use objects its
    section lists there, separated only by white space and comment lines, each closed by
    its line ending (the header line is one): bytes no entry accounts for, such as an
    unlisted indirect object or an object header inside a comment, are reached by no
    cross-reference and would escape every check, so they fail."""
    spans = sorted((f, f + _whole_object(raw[f:end], num)[0])  # validated by _section_at already
                   for num, (kind, f, *_) in entries.items() if kind == 1 and start <= f < end)
    pos = start
    for f, e in spans + [(end, end)]:
        if f < pos:
            return f"objects overlap at offset {f}"
        if not re.fullmatch(rb"(?:[\x00\t\n\x0c\r ]|%[^\r\n]*(?:\r\n|\r|\n))*", raw[pos:f]):
            return f"bytes at offsets {pos}-{f} are not accounted for by any cross-reference entry of the revision ending at {end}"
        pos = e
    return None


def _superseded_streams(raw: bytes, sections: list, merged: dict[int, Entry]) -> str | None:
    """pypdf exposes only the effective entry of each object, so a stream that a later
    revision supersedes is decoded here: within the bytes before its own section it must
    carry a parsable filter chain that is empty or exactly ``/FlateDecode``, inflate
    strictly, and satisfy its ``/DecodeParms``."""
    for entries, _, _, _, bound, _ in sections:
        for num, entry in entries.items():
            if entry[0] != 1 or entry[1] == bound or merged.get(num) == entry:
                continue
            parsed = _whole_object(raw[entry[1]:bound], num)
            if isinstance(parsed, str):
                return f"superseded {parsed}"
            _, d, data = parsed
            if d is None or data is None:
                continue
            names = _filter_names(d)
            if names is None:
                return f"superseded stream object {num} has an unparsable /Filter"
            if names not in ([], [b"FlateDecode"]):
                return f"superseded stream object {num} has an unsupported filter chain"
            if names:
                inflater = zlib.decompressobj()
                try:
                    out = inflater.decompress(data, MAX_STREAM_BYTES + 1)
                except zlib.error as e:
                    return f"superseded stream object {num} does not inflate ({e})"
                if len(out) > MAX_STREAM_BYTES or not inflater.eof or inflater.unused_data:
                    return f"superseded stream object {num} does not inflate to a complete deflate member within the ceiling"
                if isinstance(unfiltered := _unfilter(d, out), str):
                    return f"superseded stream object {num}: {unfiltered}"
    return None


ObjStm = tuple[list[tuple[int, int]], bytes, int, list[str | None]]
"""A decoded object stream: ``(header pairs (object number, offset), decoded data, /First,
per-member problem or None)``."""


def _objstm(raw: bytes, table: dict[int, Entry], container: int, cache: dict[int, ObjStm | str]) -> ObjStm | str:
    """Decode the object stream that ``container`` names in ``table`` (cached by its byte
    offset): an in-use object whose top-level ``/Type`` is ``/ObjStm`` with whole-integer
    ``/N``, ``/First`` and ``/Length``, a Flate or unfiltered body that inflates strictly
    and satisfies its ``/DecodeParms``, a header of exactly ``/N`` (object number, offset)
    pairs whose offsets lie inside the data, and every member parsed as one complete
    object ending before the next member.  A problem is returned as a string."""
    holder = table.get(container)
    if holder is None or holder[0] != 1:
        return f"object {container}, which is not an in-use object"
    if holder[1] in cache:
        return cache[holder[1]]
    at = raw[holder[1]:]
    head = re.match(rb"\d+[\x00\t\n\x0c\r ]+\d+[\x00\t\n\x0c\r ]+obj[\x00\t\n\x0c\r ]*", at)
    parsed = _dict_parse(at, head.end())
    items, end = parsed if parsed else ({}, head.end())
    fields = [_int_value(items.get(k, b"")) for k in (b"N", b"First", b"Length")]
    body = re.match(rb"[\x00\t\n\x0c\r ]*stream(?:\r\n|\n)", at[end:end + 16]) if parsed else None
    if not parsed or _name_value(items.get(b"Type", b"")) != b"ObjStm" or None in fields or not body:
        result: ObjStm | str = f"object {container}, which is not an object stream with whole-integer /N, /First and /Length"
    else:
        n, first, length = fields
        start = end + body.end()
        data = at[start:start + length]
        names = _names_of(items[b"Filter"]) if b"Filter" in items else []
        if len(data) < length or not re.match(rb"(?:\r\n|\r|\n)endstream[\x00\t\n\x0c\r ]*endobj(?=[\x00\t\n\x0c\r /\[\]<>(){}%]|$)", at[start + length:start + length + 32]):
            result = f"object stream {container}, whose body does not match its /Length or is not closed by endstream and endobj"
        elif names is None or names not in ([], [b"FlateDecode"]):
            result = f"object stream {container}, whose filter chain is unparsable or unsupported"
        else:
            if names:
                inflater = zlib.decompressobj()
                try:
                    data = inflater.decompress(data, MAX_STREAM_BYTES + 1)
                except zlib.error:
                    data = None
                if data is None or len(data) > MAX_STREAM_BYTES or not inflater.eof or inflater.unused_data:
                    data = None
            if data is not None and names:
                data = _unfilter(at[head.end():end], data)  # undo any declared predictor before reading the header
            if data is None:
                result = f"object stream {container}, whose body does not inflate to a complete deflate member within the ceiling"
            elif isinstance(data, str):
                result = f"object stream {container}: {data}"
            else:
                tokens = [t for t in re.split(rb"[\x00\t\n\x0c\r ]+", data[:first]) if t]
                if len(tokens) != 2 * n or not all(t.isdigit() for t in tokens):
                    result = f"object stream {container}, whose header is not /N pairs of integers"
                else:
                    pairs = [(int(tokens[2 * k]), int(tokens[2 * k + 1])) for k in range(n)]
                    starts = [first + o for _, o in pairs]
                    if first > len(data):
                        result = f"object stream {container}, whose /First lies outside the data"
                    elif 0 < first < len(data) and data[first - 1] not in _WSB and data[first] not in b"\x00\t\n\x0c\r /[]<>(){}%":
                        result = f"object stream {container}, whose header does not end at a token boundary at /First"
                    elif n == 0 and not re.fullmatch(rb"[\x00\t\n\x0c\r ]*", data[first:]):
                        result = f"object stream {container}, which declares no members but carries data"
                    elif not all(st < len(data) for st in starts):
                        result = f"object stream {container}, whose header offsets leave the data"
                    elif any(b <= a for a, b in zip(starts, starts[1:])):
                        result = f"object stream {container}, whose member offsets are not strictly increasing"
                    elif len({n for n, _ in pairs}) != len(pairs):
                        result = f"object stream {container}, whose header repeats an object number"
                    else:
                        members = []
                        for k, st in enumerate(starts):
                            bound = min([x for x in starts if x > st] + [len(data)])
                            e = _object_end(data, st)
                            members.append(None if e is not None and e <= bound and re.fullmatch(rb"[\x00\t\n\x0c\r ]*", data[e:bound])
                                           else f"member {k} of object stream {container} is not one complete object within its bounds")
                        result = (pairs, data, first, members)
    cache[holder[1]] = result
    return result


def _object_streams(raw: bytes, table: dict[int, Entry], cache: dict, introduced: dict[int, Entry]) -> str | None:
    """Every effective type-2 entry of a revision must name, in its effective ``table``,
    an object stream whose indexed header member is the entry's own object number and
    parses as one complete object (findings 83, 87, 89 and 91: pypdf resolves only the
    final effective entries, and an inherited row must still hold after its container is
    replaced).  Conversely, every member of an object stream that the section itself
    ``introduced`` must be listed by a type-2 entry naming that container and index
    (finding 103); a later revision may still replace a member by a direct object."""
    for num, (kind, container, index, _) in table.items():
        if kind != 2:
            continue
        stm = _objstm(raw, table, container, cache)
        if isinstance(stm, str):
            return f"type-2 entry for object {num} names {stm}"
        pairs, _, _, members = stm
        if index >= len(pairs):
            return f"type-2 entry for object {num} has index {index} beyond /N {len(pairs)} of object stream {container}"
        if pairs[index][0] != num:
            return f"type-2 entry for object {num} has index {index}, but member {index} of object stream {container} is object {pairs[index][0]}"
        if members[index]:
            return f"type-2 entry for object {num}: {members[index]}"
    for container, holder in introduced.items():
        if holder[0] != 1:
            continue
        at = raw[holder[1]:]
        items = _dict_items(at, re.match(rb"\d+[\x00\t\n\x0c\r ]+\d+[\x00\t\n\x0c\r ]+obj[\x00\t\n\x0c\r ]*", at).end())
        if items is not None and _name_value(items.get(b"Type", b"")) == b"ObjStm":
            stm = _objstm(raw, table, container, cache)  # decoded whether or not any type-2 entry names it
            if isinstance(stm, str):
                return f"object stream introduced by this section: {stm}"
            for k, (num, _) in enumerate(stm[0]):
                row = table.get(num)
                if row is None or row[0] != 2 or row[1] != container or row[2] != k:
                    return f"member {k} of object stream {container} declares object {num}, which has no matching type-2 entry in this revision"
    return None


def _ref_value(value: bytes) -> tuple[int, int] | None:
    m = re.fullmatch(rb"(\d+)[\x00\t\n\x0c\r ]+(\d+)[\x00\t\n\x0c\r ]+R", value)
    return (int(m.group(1)), int(m.group(2))) if m else None


def _refs_value(value: bytes) -> list[tuple[int, int]] | None:
    """``value`` as a list of indirect references if it is an array of nothing else."""
    m = re.fullmatch(rb"\[[\x00\t\n\x0c\r ]*((?:\d+[\x00\t\n\x0c\r ]+\d+[\x00\t\n\x0c\r ]+R[\x00\t\n\x0c\r ]*)*)\]", value)
    return [(int(a), int(b)) for a, b in re.findall(rb"(\d+)[\x00\t\n\x0c\r ]+(\d+)[\x00\t\n\x0c\r ]+R", m.group(1))] if m else None


def _resolve(raw: bytes, table: dict[int, Entry], ref: tuple[int, int], cache: dict) -> dict[bytes, bytes] | str:
    """Top-level items of the dictionary object ``ref`` names in a revision's effective
    ``table``: an in-use object at its offset (its generation must match) or a member of a
    decoded object stream (generation 0).  A problem is returned as a string."""
    num, gen = ref
    entry = table.get(num)
    if entry is None or entry[0] == 0:
        return f"object {num} {gen} R is not in use"
    if entry[0] == 1:
        if entry[2] != gen:
            return f"object {num} {gen} R names generation {gen}, but object {num} has generation {entry[2]}"
        at = raw[entry[1]:]
        parsed = _dict_parse(at, re.match(rb"\d+[\x00\t\n\x0c\r ]+\d+[\x00\t\n\x0c\r ]+obj[\x00\t\n\x0c\r ]*", at).end())
        if parsed is None:
            return f"object {num} {gen} R is not a dictionary"
        if not re.match(rb"[\x00\t\n\x0c\r ]*endobj(?=[\x00\t\n\x0c\r /\[\]<>(){}%]|$)", at[parsed[1]:parsed[1] + 16]):
            return f"object {num} {gen} R is a stream or is not closed by endobj, so it cannot serve as a dictionary node"
        items = parsed[0]
    else:
        if gen != 0:
            return f"object {num} {gen} R names a compressed object with a nonzero generation"
        stm = _objstm(raw, table, entry[1], cache)
        if isinstance(stm, str):
            return f"object {num} is a member of {stm}"
        pairs, data, first, members = stm
        if entry[2] >= len(pairs) or pairs[entry[2]][0] != num or members[entry[2]]:
            return f"object {num} is not a well-formed member {entry[2]} of object stream {entry[1]}"
        items = _dict_items(data, first + pairs[entry[2]][1])
    return items if items is not None else f"object {num} {gen} R is not a dictionary"


def _page_tree(raw: bytes, table: dict[int, Entry], ref: tuple[int, int], cache: dict,
               parent: tuple[int, int] | None = None, seen: set | None = None, depth: int = 0) -> int | str:
    """The number of pages under node ``ref`` of a revision's page tree: a ``/Page`` is a
    leaf; a ``/Pages`` node must hold ``/Kids`` (an array of references, each a node naming
    this one as ``/Parent``) and a ``/Count`` equal to the pages beneath it.  Cycles and
    nesting beyond 64 levels fail.  A problem is returned as a string."""
    seen = set() if seen is None else seen
    if ref in seen or depth > 64:
        return f"page tree revisits object {ref[0]} or nests too deeply"
    seen.add(ref)
    items = _resolve(raw, table, ref, cache)
    if isinstance(items, str):
        return f"page tree: {items}"
    if parent is None and b"Parent" in items:
        return f"the root of the page tree, object {ref[0]}, carries a /Parent"
    if parent is not None and _ref_value(items.get(b"Parent", b"")) != parent:
        return f"page tree node {ref[0]} does not name its parent {parent[0]}"
    kind = _name_value(items.get(b"Type", b""))
    if kind == b"Page":
        return 1 if parent is not None else f"the root of the page tree, object {ref[0]}, is a /Page rather than /Pages"
    if kind != b"Pages":
        return f"page tree node {ref[0]} is neither /Pages nor /Page"
    kids, count = _refs_value(items.get(b"Kids", b"")), _int_value(items.get(b"Count", b""))
    if kids is None or count is None:
        return f"page tree node {ref[0]} lacks a /Kids array of references or a whole-integer /Count"
    total = 0
    for kid in kids:
        below = _page_tree(raw, table, kid, cache, ref, seen, depth + 1)
        if isinstance(below, str):
            return below
        total += below
    return total if total == count else f"page tree node {ref[0]} declares /Count {count} but holds {total} pages"


def _catalog(raw: bytes, root: tuple[int, int], table: dict[int, Entry], cache: dict) -> str | None:
    """A trailer's ``/Root`` must resolve, in that revision's effective ``table``, to a
    dictionary whose top-level ``/Type`` is ``/Catalog`` and whose ``/Pages`` reference
    heads a consistent, nonempty page tree (findings 88, 90 and 102: pypdf reads only the
    final trailer's root and page tree)."""
    items = _resolve(raw, table, root, cache)
    if isinstance(items, str):
        return f"trailer /Root {root[0]} {root[1]} R: {items}"
    if _name_value(items.get(b"Type", b"")) != b"Catalog":
        return f"trailer /Root {root[0]} {root[1]} R does not resolve to a dictionary whose top-level /Type is /Catalog"
    pages = _ref_value(items.get(b"Pages", b""))
    if pages is None:
        return f"catalog {root[0]} lacks a /Pages reference"
    total = _page_tree(raw, table, pages, cache)
    if isinstance(total, str):
        return total
    return None if total > 0 else f"catalog {root[0]} has an empty page tree"


def _xref_chain(raw: bytes, off: int) -> str | int:
    """Walk the cross-reference sections from ``off`` along ``/Prev`` (a classic table's
    ``/XRefStm`` companion stream is merged beneath it), then replay them oldest first: at
    each section the free list is validated on the effective table and the trailer
    ``/Size`` must be one more than its highest object number, since every prefix of the
    chain was once a complete file.  A problem, or the highest object number of the final
    merged table."""
    seen, sections = [], []
    while off is not None:
        section = _section_at(raw, off, seen)
        if isinstance(section, str):
            return section
        entries, size, prev, xrefstm, _, root = section
        here = seen[-1]
        if any(link is not None and link >= here for link in (prev, xrefstm)):
            return f"cross-reference section at offset {here} links forward (/Prev or /XRefStm {prev if prev is not None and prev >= here else xrefstm}); earlier revisions precede it"
        term = re.match(rb"[\x00\t\n\x0c\r ]*startxref(?:\r\n|\r|\n)(\d+)(?:\r\n|\r|\n)%%EOF(?:\r\n|\r|\n|$)", raw[section[4]:section[4] + 64])
        if not term or int(term.group(1)) != here:
            return f"cross-reference section at offset {here} is not followed by 'startxref', {here} and %%EOF on separate lines, so its revision was never a complete file"
        after = section[4] + term.end()  # where the next revision's body begins
        off = prev
        classic, sizes, roots = xrefstm is not None or raw.startswith(b"xref", here), (size,), (root,)
        if xrefstm is not None:
            companion = _section_at(raw, xrefstm, seen)
            if isinstance(companion, str):
                return f"/XRefStm: {companion}"
            if companion[2] is not None and (companion[2] >= xrefstm or companion[2] != prev):
                return f"/XRefStm companion at offset {xrefstm} carries /Prev {companion[2]}, which is not the trailer's earlier /Prev"
            # the table's own entries take precedence; both /Size and /Root values must hold
            entries, sizes, roots = {**companion[0], **entries}, (size, companion[1]), (root, companion[5])
            num, gen = (int(x) for x in re.match(rb"(\d+)[\x00\t\n\x0c\r ]+(\d+)[\x00\t\n\x0c\r ]+obj", raw[xrefstm:]).groups())
            if entries.get(num, (None,))[:3] != (1, xrefstm, gen):  # the table must not free or move the companion it names
                return f"/XRefStm companion object {num} {gen} at offset {xrefstm} is not an in-use entry at that offset once the classic table's entries take precedence"
        sections.append((entries, sizes, roots, classic, here, after))
    # the newest section's terminator must be the one the file ends with: bytes after it (a
    # duplicate startxref/%%EOF pair, say) belong to no revision the walk has seen
    if raw[sections[0][5]:].strip(b"\r\n"):
        return (f"{len(raw) - sections[0][5]} bytes follow the newest revision's %%EOF at offset {sections[0][5]}, "
                "so the terminator the file ends with is not its own")
    merged, cache = {}, {}
    for entries, sizes, roots, classic, _, _ in reversed(sections):
        merged = {**merged, **entries}  # newer sections win
        if problem := _free_list(merged, classic) or _object_streams(raw, merged, cache, entries):
            return problem
        for size in sizes:  # the trailer's /Size and, in a hybrid section, the companion stream's
            if size != max(merged) + 1:
                return f"trailer /Size {size} is not one more than the highest object number {max(merged)} of its section"
        for root in roots:
            if problem := _catalog(raw, root, merged, cache):
                return problem
    for i, (entries, _, _, _, here, _) in enumerate(sections):  # newest first; each body starts where the previous revision ended
        if problem := _covered(raw, sections[i + 1][5] if i + 1 < len(sections) else 0, here, entries):
            return problem
    return _superseded_streams(raw, sections, merged) or max(merged)


def _inflate_strictly(obj) -> str | None:
    """Every stream must carry no filter or exactly ``/FlateDecode``, and a Flate body must
    inflate to end of stream with no trailing bytes.  pypdf's own decoder returns partial or
    empty data on a corrupt payload instead of raising, so the inflate is done here."""
    filters = obj.get("/Filter")
    names = [] if filters is None else [str(f) for f in (filters if isinstance(filters, list) else [filters])]
    if names not in ([], ["/FlateDecode"]):
        return f"unsupported stream filter chain {names}"
    if names:
        d = zlib.decompressobj()
        try:
            out = d.decompress(obj._data, MAX_STREAM_BYTES + 1)
        except zlib.error as e:
            return f"stream does not inflate ({e})"
        if len(out) > MAX_STREAM_BYTES:
            return f"stream inflates beyond the ceiling of {MAX_STREAM_BYTES} bytes"
        if not d.eof or d.unused_data:
            return "stream does not inflate to a complete deflate member"
    obj.get_data()
    return None


def _full_parse(path: Path, top: int) -> str | None:
    """Parse the whole file with pypdf in strict mode, dereference and decode every object.

    This covers what the structural checks above do not model: ``/Prev`` chains,
    object streams and their members, filter and predictor parameters, the body of
    every stream, and the page tree.  ``/Size`` must be one more than the highest
    object number in the whole cross-reference chain: ``top`` from the structural walk
    counts free entries, which pypdf does not record, and pypdf's in-use entries cover
    any hybrid ``/XRefStm`` section.  A missing or broken parser is a failure, never a
    skip.
    """
    try:
        from pypdf import PdfReader
        from pypdf.generic import IndirectObject, StreamObject
    except BaseException as e:  # noqa: BLE001 - a broken parser install must fail closed
        return f"pypdf is not importable ({type(e).__name__}); install the pinned dev dependency"
    try:
        reader = PdfReader(str(path), strict=True)
        size = int(reader.trailer["/Size"])
        ids = [(i, g) for g, table in reader.xref.items() for i in table] + [(i, 0) for i in reader.xref_objStm]
        for idnum, gen in ids:
            obj = reader.get_object(IndirectObject(idnum, gen, reader))
            if isinstance(obj, StreamObject) and (err := _inflate_strictly(obj)):
                return f"object {idnum}: {err}"
        pages = len(reader.pages)
    except Exception as e:  # noqa: BLE001 - any parser failure is a guard failure
        return f"full parse failed ({type(e).__name__}: {str(e)[:120]})"
    top = max(top, *(i for i, _ in ids)) if ids else top
    if not ids or size != top + 1 or pages == 0:
        return f"full parse inconsistent: /Size {size} against highest object number {top}, {len(ids)} objects, {pages} pages"
    return None


def check_pdf(path: Path) -> list[str]:
    raw = path.read_bytes()
    if not raw.startswith(b"%PDF-"):
        return [f"{path}: missing %PDF- signature (got {raw[:5]!r})"]
    tail = raw[-1024:]
    final = re.search(rb"%%EOF[ \t]*(?:\r\n|\r|\n)*$", tail)
    if not final:
        return [f"{path}: the file does not end with %%EOF (truncated or trailing bytes?)"]
    eof = final.start()
    # the trailer that counts is the last startxref before the final %%EOF
    sx = tail.rfind(b"startxref", 0, eof)
    if sx < 0:
        return [f"{path}: no startxref before the final %%EOF"]
    m = re.fullmatch(rb"startxref(?:\r\n|\r|\n)(\d+)(?:\r\n|\r|\n)", tail[sx:eof])
    if not m:
        return [f"{path}: malformed startxref before the final %%EOF"]
    off = int(m.group(1))
    if off >= len(raw):
        return [f"{path}: startxref offset {off} beyond end of file ({len(raw)} bytes)"]
    chain = _xref_chain(raw, off)
    if isinstance(chain, str):
        return [f"{path}: {chain}"]
    problem = _full_parse(path, chain)
    return [f"{path}: {problem}"] if problem else []


def _regular(p: Path, directory: Path) -> str | None:
    """A problem unless ``p`` is a regular file, not a symbolic link, that lives in
    ``directory`` itself once both are resolved: a same-named link could otherwise point the
    check at a file that is not the manuscript source.  The directory itself is checked
    once by ``main``, since a linked directory makes every child look regular."""
    if not p.is_file():
        return "missing"
    if p.is_symlink() or p.resolve().parent != directory.resolve():
        return "a symbolic link or resolving outside the manuscripts directory"
    return None


def main(argv: list[str]) -> int:
    directory = Path(argv[0]) if argv else ROOT / "manuscripts"
    manifest = directory / "MANIFEST"
    problems = []
    if directory.is_symlink():
        print("FAIL", f"{directory}: the manuscripts directory is a symbolic link, so its contents are not the manuscript sources")
        return 1
    if (why := _regular(manifest, directory)) is not None:
        problems.append(f"{manifest}: missing manifest of required files" if why == "missing" else f"{manifest}: manifest of required files is {why}")
        required = []
    else:
        names = [l.strip() for l in manifest.read_text().splitlines() if l.strip()]
        escaping = [n for n in names if Path(n).is_absolute() or Path(n).name != n]
        problems += [f"{manifest}: entry {n!r} is not a bare file name inside the manuscripts directory" for n in escaping]
        required = [directory / n for n in names if n not in escaping]
        if not names:
            problems.append(f"{manifest}: empty manifest")
    for p in required:
        if (why := _regular(p, directory)) is not None:
            problems.append(f"{p}: required by the manifest but {why}")
    words = directory / "TEX_CONTROL_WORDS"
    allowed = frozenset()
    if (why := _regular(words, directory)) is not None:
        problems.append(f"{words}: {'missing list of allowed control words' if why == 'missing' else 'list of allowed control words is ' + why}")
    else:
        entries = words.read_text().splitlines()
        # a name is letters only: @ is not a letter under the document catcodes the guard assumes
        # (nothing may change them), so \\endinput@foo is \\endinput followed by text, which the
        # scanner would take for one allowed word if @ could be listed
        if not entries or entries != sorted(set(entries)) or not all(re.fullmatch(r"[a-zA-Z]+", w) for w in entries):
            problems.append(f"{words}: must list one control word name per line, letters only, sorted and without repetition")
        elif banned := sorted(set(entries) & _TEX_STOPS):
            problems.append(f"{words}: {', '.join(chr(92) + w for w in banned)} cannot be allowed; the guard cannot follow them")
        else:
            allowed = frozenset(entries)
    inputs = sorted(p for p in directory.iterdir() if p.suffix in _TEX_INPUTS or p.is_dir()) if directory.is_dir() else []
    problems += [f"{p}: {'a subdirectory, from which a source could load a TeX input file the guard does not read' if p.is_dir() else 'a TeX input file that a source could load in place of the installed one'}" for p in inputs]
    present = sorted(set(directory.glob("*.tex")) | set(directory.glob("*.pdf")) | {p for p in required if p.suffix in (".tex", ".pdf")}) if directory.is_dir() else []
    checked = 0
    for p in present:
        if (why := _regular(p, directory)) is not None:
            problems += [f"{p}: {why}"] if p not in required else []  # required files were reported above
            continue
        problems += check_tex(p, allowed) if p.suffix == ".tex" else check_pdf(p)
        checked += 1
    if not any(p.suffix == ".tex" for p in required) or not any(p.suffix == ".pdf" for p in required):
        problems.append(f"{manifest}: must list at least one .tex and one .pdf")
    for m in problems:
        print("FAIL", m)
    if not problems:
        print(f"OK manuscript sources: {len(required)} required files present, {checked} .tex/.pdf checked")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
