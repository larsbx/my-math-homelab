"""The manuscript-source guard fails closed on missing, mangled, and truncated files."""
import re
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "check_manuscript_source.py"
SRC = ROOT / "manuscripts"


def run(directory: Path) -> tuple[int, str]:
    r = subprocess.run([sys.executable, str(SCRIPT), str(directory)], capture_output=True, text=True)
    return r.returncode, r.stdout


@pytest.fixture
def copy(tmp_path):
    d = tmp_path / "manuscripts"
    d.mkdir()
    for name in (SRC / "MANIFEST").read_text().split():
        shutil.copy(SRC / name, d / name)
    shutil.copy(SRC / "MANIFEST", d / "MANIFEST")
    return d


def allow(directory: Path, words: str) -> None:
    """Add ``words`` (space-separated) to the copied list of allowed control words."""
    listed = directory / "TEX_CONTROL_WORDS"
    listed.write_text("\n".join(sorted(set(listed.read_text().split()) | set(words.split()))) + "\n")



def classic_pdf(objs=None, extra_trailer=b"", edit=None, lead=b""):
    """A complete classic-table PDF (catalog, page tree, one page) with ``lead`` written
    between the header line and the first object; `edit` mutates the bytes."""
    objs = objs or [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>",
    ]
    out, offs = b"%PDF-1.4\n" + lead, []
    for i, body in enumerate(objs, 1):
        offs.append(len(out))
        out += b"%d 0 obj\n%s\nendobj\n" % (i, body)
    xref = len(out)
    out += b"xref\n0 %d\n0000000000 65535 f \n" % (len(objs) + 1)
    out += b"".join(b"%010d 00000 n \n" % o for o in offs)
    out += b"trailer\n<< /Size %d /Root 1 0 R %s>>\nstartxref\n%d\n%%%%EOF\n" % (len(objs) + 1, extra_trailer, xref)
    return edit(out) if edit else out


def xref_pdf(rows=None, dict_extra=b"", predictor=False, compress=True, gen_bytes=1, xref_num=3, eol=b"\n"):
    """A complete PDF whose cross-reference is a stream (object ``xref_num``, written where
    object 3 is listed; catalog, one-page tree; page is object 4), with ``/W [1 2 gen_bytes]``."""
    import zlib

    out = b"%PDF-1.5\n"
    o1 = len(out)
    out += b"1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n"
    o2 = len(out)
    out += b"2 0 obj\n<< /Type /Pages /Kids [4 0 R] /Count 1 >>\nendobj\n"
    o4 = len(out)
    out += b"4 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>\nendobj\n"
    o3 = len(out)
    # object 0: free, next free 0, generation column saturated (as pdfTeX writes it in one byte)
    table = [b"\x00\x00\x00" + b"\xff" * gen_bytes] + [b"\x01" + o.to_bytes(2, "big") + bytes(gen_bytes) for o in (o1, o2, o3, o4)]
    if rows is not None:
        table = rows(table, o1, o2, o3)
    if predictor:
        prev, enc = bytes(3 + gen_bytes), b""
        for r in table:
            enc += b"\x02" + bytes((a - b) & 0xFF for a, b in zip(r, prev))
            prev = r
        body = zlib.compress(enc)
    else:
        body = zlib.compress(b"".join(table)) if compress else b"".join(table)
    flt = b"/Filter /FlateDecode " if (compress or predictor) else b""
    out += b"%d 0 obj\n<< /Type /XRef /Size 5 /W [1 2 %d] /Root 1 0 R " % (xref_num, gen_bytes) + flt + dict_extra + b"/Length %d >>\nstream\n" % len(body)
    out += body + eol + b"endstream\nendobj\nstartxref\n%d\n%%%%EOF\n" % o3
    return out


def test_repository_manuscripts_pass():
    code, out = run(SRC)
    assert code == 0 and out.startswith("OK"), out


def test_intact_copy_passes(copy):
    assert run(copy)[0] == 0


def test_mangled_tex_fails(copy):
    tex = next(copy.glob("*.tex"))
    tex.write_bytes(bytes(b ^ 0xA5 for b in tex.read_bytes()))
    code, out = run(copy)
    assert code == 1 and ("not valid UTF-8" in out or "\\documentclass" in out)


def test_commented_document_sentinels_fail(copy):
    tex = next(copy.glob("*.tex"))
    text = tex.read_text()
    allow(copy, "newif ifdraft else fi iffalse iff ifthenelse inputencoding csnamex begingroup endgroup foo renewcommand newenvironment "
                "comment "
                "DeclareMathOperator Tr DeclareGraphicsExtensions newcounter newlength len newdimen dim barx baz providecommand")
    i = text.rindex("\\end{document}")
    tex.write_text(text[:i] + "%" + text[i:])  # the only \end{document} is now a comment
    code, out = run(copy)
    assert code == 1 and "as standalone uncommented top-level lines outside conditionals" in out, out
    tex.write_text(text.replace("\\begin{document}", "%\\begin{document}", 1))
    code, out = run(copy)
    assert code == 1 and "as standalone uncommented top-level lines outside conditionals" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\begin{document} % 100\\% active", 1))  # an escaped % is not a comment
    assert run(copy)[0] == 0
    tex.write_text(text[:i] + "\\\\%" + text[i:])  # \\ is a control sequence, so this % starts a comment
    code, out = run(copy)
    assert code == 1 and "as standalone uncommented top-level lines outside conditionals" in out, out
    tex.write_text(text[:i] + "\\% not a comment\n" + text[i:])  # an escaped percent on the line before
    assert run(copy)[0] == 0
    reversed_line = text.replace("\\begin{document}", "", 1)[:i] + "\\end{document} \\begin{document}" + text[i + len("\\end{document}"):]
    tex.write_text(reversed_line)  # both sentinels on one line, in the wrong order
    code, out = run(copy)
    assert code == 1 and "as standalone uncommented top-level lines outside conditionals" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\end{document}\n\\begin{document}", 1))  # an early end before a valid pair
    code, out = run(copy)
    assert code == 1 and "as standalone uncommented top-level lines outside conditionals" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\\\begin{document}", 1)[:i] + "\\" + text[i:])  # \\ then a bare word, twice
    code, out = run(copy)
    assert code == 1 and "as standalone uncommented top-level lines outside conditionals" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\\\\n\\begin{document}", 1))  # \\ on the line before the real sentinel
    assert run(copy)[0] == 0
    def wrapped(before_begin: str, after_begin: str, before_end: str, after_end: str) -> str:
        """``text`` with both sentinels wrapped as given; the end is spliced first so ``i`` stays valid."""
        end = before_end + "\\end{document}" + after_end
        return (text[:i] + end + text[i + len("\\end{document}"):]).replace("\\begin{document}", before_begin + "\\begin{document}" + after_begin, 1)

    tex.write_text(wrapped("\\newcommand{\\fake}{", "}", "\\newcommand{\\stop}{", "}"))  # macro bodies only
    code, out = run(copy)
    assert code == 1 and "as standalone uncommented top-level lines outside conditionals" in out, out
    tex.write_text(text.replace("\\begin{document}", "  \\begin{document}  \t", 1))  # surrounding white space is fine
    assert run(copy)[0] == 0
    tex.write_text(wrapped("\\newcommand{\\fake}{\n", "\n}", "\\newcommand{\\stop}{\n", "\n}"))  # multiline macro bodies
    code, out = run(copy)
    assert code == 1 and "as standalone uncommented top-level lines outside conditionals" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\{ an escaped brace \\}\n\\begin{document}", 1))  # escaped braces do not nest
    assert run(copy)[0] == 0
    tex.write_text(wrapped("\\iffalse\n", "", "", "\n\\fi"))  # a skipped branch
    code, out = run(copy)
    assert code == 1 and "as standalone uncommented top-level lines outside conditionals" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\newif\\ifdraft\n\\ifdraft x\\else y\\fi\n$a \\iff b$ \\ifthenelse{1}{2}{3}\n\\begin{document}", 1))
    assert run(copy)[0] == 0  # a balanced declared conditional, the \\iff symbol and a brace-argument macro before the sentinel
    tex.write_text(text.replace("\\begin{document}", "\\newif\\ifdraft\n\\ifdraft\n\\begin{document}", 1))  # a declared conditional left open
    code, out = run(copy)
    assert code == 1 and "outside conditionals" in out, out
    tex.write_text(wrapped("\\newcommand{\\fake}{\\fi}\n\\iffalse\n", "", "", "\n\\fi"))  # a \\fi in a macro body
    code, out = run(copy)
    assert code == 1 and "conditional token inside a brace group" in out, out
    tex.write_text(wrapped("{\\iffalse}\n", "", "", "\n\\else\n}\n\\fi"))  # an opener inside an executed group
    code, out = run(copy)
    assert code == 1 and "conditional token inside a brace group" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\newcommand{\\fake}{\\iffalse}\n\\begin{document}", 1))  # neither can be told apart
    code, out = run(copy)
    assert code == 1 and "conditional token inside a brace group (line" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\endinput\n\\begin{document}", 1))  # TeX stops before the sentinels
    code, out = run(copy)
    assert code == 1 and "\\endinput on line" in out and "precedes" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\newcommand{\\halt}{\\endinput}\n\\begin{document}", 1))  # even inside a macro body
    code, out = run(copy)
    assert code == 1 and "\\endinput on line" in out, out
    for word in ("\\csname endinput\\endcsname", "\\input{other}", "\\catcode`\\%=12", "\\scantokens{x}", "\\ExplSyntaxOn",
                 "\\toks0={\\begin{}}\n\\expandafter\\def\\the\\toks0", "{\\aftergroup\\def}\\begin{}", "\\let\\d\\def\n\\d\\begin{}",
                 "\\edef\\x{\\noexpand\\def\\noexpand\\begin{}}\\x", "\\everypar{\\renewcommand\\end{}}", "\\newtoks\\begin",
                 "\\font\\end=cmr10", "\\read16 to \\begin"):  # constructions the guard cannot follow
        tex.write_text(text.replace("\\begin{document}", word + "\n\\begin{document}", 1))
        code, out = run(copy)
        assert code == 1 and "precedes \\end{document}; the guard cannot follow it" in out, (word, out)
    tex.write_text(text.replace("\\begin{document}", "\\newcommand{\\csnamex}{}\\inputencoding{utf8} \\csnamex\n\\begin{document}", 1))  # longer control words differ
    assert run(copy)[0] == 0
    tex.write_text(text.replace("\\begin{document}", "\\end^^69nput\n\\begin{document}", 1))  # ^^69 is i to TeX's input processor
    code, out = run(copy)
    assert code == 1 and "TeX ^^ notation on line" in out, out
    for redefinition in ("\\def\\begin#1{}\n\\def\\end#1{}", "\\def\\begin{}\n\\def\\end{}", "\\let\\begin\\relax", "\\renewcommand{\\end}[1]{}",
                         "\\renewcommand\\begin{}", "\\global\\let\\end{}", "\\NewCommandCopy\\begin{\\relax}", "\\renewenvironment{document}{}{}",
                         "\\RenewDocumentEnvironment{document}{}{}{}", "\\let\\document\\relax", "\\let\\foo\\begin",
                         "\\def\n\\begin{}\n\\def\n\\end{}", "\\def%\n\\begin{}", "\\renewcommand\n{\\end}{}", "\\global\n\n\\let\n\\end{}",
                         "\\renewenvironment\n{document}{}{}", "\\NewDocumentEnvironment\n*\n{ document }{}{}{}",  # line endings after a control word are white space
                         "\\renewcommand*\\begin{}\n\\renewcommand*\\end{}", "\\newcommand*{\\end}{}", "\\DeclareRobustCommand*\n\\begin{}",  # starred definers
                         "\\@namedef{begin}{}", "\\@namedef{ enddocument }{}", "\\@namelet\n{end}{relax}",  # definers spelling their target as text
                         "\\DeclareTextSymbol\\begin{OT1}{65}", "\\newcount\\begin{}",  # other macros that target a control word
                         "\\newcommand{\\d}[1]{\\renewcommand#1{}}\n\\d\\begin{}", "\\newcommand\\d{\\renewcommand}\n\\d\\begin{}",  # wrappers
                         "\\renewcommand{#1}{}", "\\newcommand", "\\newcommand\\foo\\bar", "\\NewCommandCopy\\foo\\bar",  # a definer whose target is not a control word right there, followed by a body
                         "\\renewenvironment{begin}{}{}", "\\newenvironment*{ end }{}{}",  # environment definers naming a sentinel word
                         "\\newtheorem{document}{Broken}", "\\newtheorem*{end}{Broken}", "\\newtheorem\n{begin}[section]{Broken}",  # theorem environments alike
                         "\\newcommand{\\foo}{document}\n\\renewenvironment{\\foo}{}{}", "\\newcommand{\\foo}{document}\n\\newtheorem{\\foo}{Broken}",  # expanded names
                         "\\newenvironment{ doc }{}{}", "\\newenvironment{do#1}{}{}", "\\newtheorem",  # names that are not literal plain names
                         "\\newcommand{\\foo}[1]{\\begin{docu#1}}", "\\newcommand{\\foo}[1]{\\end{#1}}", "\\begin{ center }\\end{ center }"):  # environment names that are not plain
        tex.write_text(text.replace("\\begin{document}", redefinition + "\n\\begin{document}", 1))
        code, out = run(copy)
        assert code == 1 and "can change what the document sentinels mean" in out, (redefinition, out)
    tex.write_text(text.replace("\\begin{document}", "\\begingroup\\endgroup \\begin {center}\\end{center}\n\\newcommand{\\foo}{\\begin{center}\\end{center}}\n\\begin{document}", 1))
    assert run(copy)[0] == 0  # environment uses, longer control words and a macro body using a whole environment are fine
    tex.write_text(wrapped("\\begin{comment}\n", "", "", "\n\\end{comment}"))  # sentinels inside an environment that discards its body
    code, out = run(copy)
    assert code == 1 and "sits inside the environment comment" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\begin{center}\n\\begin{document}", 1))  # an environment left open at the opening sentinel
    code, out = run(copy)
    assert code == 1 and "sits inside the environment center" in out, out
    tex.write_text(text[:i] + "\\begin{center}\n" + text[i:])  # an environment left open at the closing sentinel, which then closes center
    code, out = run(copy)
    assert code == 1 and "\\end{document} on line" in out and "closes no open environment" in out, out
    for nesting in ("\\end{center}", "\\begin{center}\\end{quote}", "\\newcommand{\\foo}{\\begin{center}}"):  # nesting the guard cannot follow
        tex.write_text(text.replace("\\begin{document}", nesting + "\n\\begin{document}", 1))
        code, out = run(copy)
        assert code == 1 and ("closes no open environment" in out or "sits inside the environment" in out), (nesting, out)
    tex.write_text(text[:i + len("\\end{document}")] + "\n\\end{center}" + text[i + len("\\end{document}"):])  # after the document is fine
    assert run(copy)[0] == 0
    tex.write_text(text.replace("\\begin{document}", "\\renewcommand{\\foo}\n{\\begin{center}\\end{center}}\n\\newenvironment\n{doc}{}{}\\newtheorem*{lem2}[doc]{Lemma}\n\\begin{document}", 1))
    assert run(copy)[0] == 0  # a line-broken definer whose target is not a sentinel, another environment and a theorem with a plain name
    tex.write_text(text.replace("\\begin{document}", "\\renewcommand*{\\foo}{\\begin{center}\\end{center}}\n\\begin{document}", 1))
    assert run(copy)[0] == 0  # a starred definer with another target
    for wrapper in ("\\newcommand{\\foo}{\\end{document}}\n\\foo", "\\newcommand{\\foo}{\\begin{document}}", "x \\end{document}"):
        tex.write_text(text.replace("\\begin{document}", wrapper + "\n\\begin{document}", 1))  # a sentinel a macro or group could execute
        code, out = run(copy)
        assert code == 1 and "is not the standalone sentinel" in out, (wrapper, out)
    tex.write_text(text.replace("\\begin{document}", "\\begin{align*}\\end{align*}\n\\begin{document}", 1))
    assert run(copy)[0] == 0  # a starred environment name is plain
    tex.write_text(text.replace("\\begin{document}", "}\n{\n\\begin{document}", 1))  # a closer before its opener sums to zero
    code, out = run(copy)
    assert code == 1 and "an unmatched closing brace on line" in out, out
    tex.write_text(wrapped("\\fi\n\\iffalse\n", "", "", "\n\\fi"))  # likewise for conditionals
    code, out = run(copy)
    assert code == 1 and "an unmatched \\fi on line" in out, out
    tex.write_text(text[:i + len("\\end{document}")] + "\n\\fi\n}" + text[i + len("\\end{document}"):])  # after the document is fine
    assert run(copy)[0] == 0
    tex.write_text(text.replace("\\begin{document}", "\\DeclareMathOperator{\\Tr}{Tr}\\newcounter{foo}\\newlength{\\len}\\newdimen\\dim\n"
                                "\\newcommand\\foo{}\\newcommand*{ \\barx }[1]{#1}\\providecommand{\\baz}{\\barx{x}}\n\\begin{document}", 1))
    assert run(copy)[0] == 0  # Declare... macros, allocators and ...command... definers naming fresh targets (a name with known arity fails closed: finding 159)
    tex.write_text(text.replace("\\begin{document}", "\\newif\n\\ifdraft\n\\ifdraft\n\\begin{document}", 1))  # a declared conditional across a line ending
    code, out = run(copy)
    assert code == 1 and "outside conditionals" in out, out
    tex.write_text(text[:i + len("\\end{document}")] + "\n\\endinput" + text[i + len("\\end{document}"):])  # after the document is fine
    assert run(copy)[0] == 0


def test_endstream_needs_a_preceding_line_ending(copy):
    pdf = next(copy.glob("*.pdf"))
    for raw, message in ((superseded_pdf(flate_stream(b"x").replace(b"\nendstream", b"endstream")), "not closed by endstream and endobj"),
                         (xref_pdf(eol=b""), "cross-reference stream body does not match /Length or is not closed by endstream"),
                         (objstm_pdf(eol=b""), "not closed by endstream and endobj")):
        pdf.write_bytes(raw)  # the line ending between the data and endstream deleted
        code, out = run(copy)
        assert code == 1 and message in out, out


def test_control_words_must_be_listed(copy):
    tex = next(copy.glob("*.tex"))
    text = tex.read_text()
    listed = copy / "TEX_CONTROL_WORDS"
    for source in ("\\csdef{begin}{}\n\\csdef{end}{}", "\\@namedef{beginfoo}{}", "\\newcommand{\\foo}{x}", "\\cslet{end}\\relax", "\\endinput@foo"):
        tex.write_text(text.replace("\\begin{document}", source + "\n\\begin{document}", 1))  # words the guard has not been told about
        code, out = run(copy)
        assert code == 1 and "is not listed in TEX_CONTROL_WORDS" in out, (source, out)
    tex.write_text(text.replace("\\begin{document}", "\\newcommand{\\foo}{x}\n\\begin{document}", 1))
    allow(copy, "foo")
    assert run(copy)[0] == 0  # once listed
    tex.write_text(text.replace("\\end{document}", "\\end{document}\n\\csdef{begin}{}", 1))
    assert run(copy)[0] == 0  # after the document TeX has stopped
    words = listed.read_text()
    allow(copy, "def")  # a control word the guard can never follow
    code, out = run(copy)
    assert code == 1 and "\\def cannot be allowed" in out, out
    for bad in (words + "A\n", "zeta\n" + words, words + "not a name\n", "", words + "x@y\n"):  # unsorted, repeated, not a name, empty, with @
        listed.write_text(bad)
        code, out = run(copy)
        assert code == 1 and "letters only, sorted and without repetition" in out, (bad[-20:], out)
    listed.write_text(words)
    tex.write_text(text)
    assert run(copy)[0] == 0
    listed.unlink()
    code, out = run(copy)
    assert code == 1 and "missing list of allowed control words" in out, out


def test_macro_parameters_stay_in_order(copy):
    tex = next(copy.glob("*.tex"))
    text = tex.read_text()
    allow(copy, "e f")
    for body in ("\\newcommand{\\e}[2]{#2#1}\n\\e{\\begin{}}\\newcommand\\f{}", "\\newcommand{\\e}[2]{#1#2#1}", "\\newcommand{\\e}[2]{\\f{#2}{#1}}",
                 "#1", "\\newcommand{\\e}[1]{##1}", "\\newcommand{\\e}[1]{#a}"):
        tex.write_text(text.replace("\\begin{document}", body + "\n\\begin{document}", 1))
        code, out = run(copy)
        assert code == 1 and "macro parameter on line" in out, (body, out)
    tex.write_text(text.replace("\\begin{document}", "\\newcommand{\\f}[1]{#1}\\newcommand{\\e}[2]{\\f{#1}{#2}}\n\\begin{document}", 1))
    assert run(copy)[0] == 0  # in order, and one parameter per body; the source's own \\Status macro and escaped \\# pass alike


def test_arguments_complete_before_sentinels_and_bodies(copy):
    tex = next(copy.glob("*.tex"))
    text = tex.read_text()
    i = text.rindex("\\end{document}")
    allow(copy, "foo sqrt newenvironment renewcommand providecommand csnamex iffalse fi DeclareRobustCommand NewCommandCopy DeclareGraphicsExtensions "
                "newif ifdraft drafttrue mathbb")
    for source in ("\\title", "\\usepackage[a]{b}\\sqrt", "\\newcommand{\\foo}[2]{}\\foo{x}", "\\newcommand{\\foo}{\\emph}\n\\foo", "\\newcommand{\\foo}{\\frac{a}}",
                   "\\newenvironment{foo}{x}{\\emph}", "\\csnamex", "\\newcommand{\\foo}[1]{#1}\\foo{\\sqrt}", "\\newcommand{\\foo}[1]{#1}\\foo\\sqrt",
                   "\\textbf{\\emph}\\textbf{x}",
                   "\\foo\n\\newcommand{\\foo}{}", "\\iffalse\n\\newcommand{\\foo}{}\n\\fi\n\\foo", "{\\newcommand{\\foo}{}}\n\\foo",  # a declaration that has not executed at the call
                   "\\newcommand{\\foo}[1]{}\\providecommand{\\foo}{}\n\\foo", "\\newcommand{\\emph}{}\n\\emph", "\\renewcommand{\\foo}{}\n\\foo",  # declarations LaTeX does not carry out
                   "\\DeclareRobustCommand{\\foo}[1]{}\\providecommand{\\foo}{}\n\\foo",  # a robust declaration, then a no-op
                   "\\newcommand{\\foo}[2][d]{}\\foo[abcdefghijk]", "\\newcommand{\\foo}[1]{}\\foo[abc",  # an optional argument longer than any bounded lookback, and an unclosed one
                   "\\newcommand{\\foo}[2][d]{}\\foo[abcdefghijk]{x}\\foo[abcdefghijk]"):  # the same after a complete call
        tex.write_text(text.replace("\\begin{document}", source + "\n\\begin{document}", 1))  # a call short of arguments, or of unknown arity
        code, out = run(copy)
        assert code == 1 and "has fewer arguments than it takes" in out, (source, out)
    for source in ("\\newcommand{\\mathbb}[3]{}\\mathbb a b",
                   "\\providecommand{\\mathbb}[3]{}\\mathbb a b",
                   "\\renewcommand{\\mathbb}[3]{}\\mathbb a b"):
        tex.write_text(text.replace("\\begin{document}", source + "\n\\begin{document}", 1))
        code, out = run(copy)
        assert code == 1 and "current definition state the guard cannot determine" in out, (source, out)
    tex.write_text(text.replace("\\begin{document}", "\\newcommand{\\foo}[3]{}\\foo a b\n\\begin{document}", 1))
    code, out = run(copy)
    assert code == 1 and "has fewer arguments than it takes" in out, out
    tex.write_text(text[:i] + "\\emph\n" + text[i:])  # likewise before the closing sentinel
    code, out = run(copy)
    assert code == 1 and "before the document sentinel" in out, out
    for definer in ("\\NewCommandCopy{\\foo}{\\emph}", "\\DeclareGraphicsExtensions{.pdf}"):  # definers the guard does not model
        tex.write_text(text.replace("\\begin{document}", definer + "\n\\begin{document}", 1))
        code, out = run(copy)
        assert code == 1 and "is a definer whose effect on control words the guard does not model" in out, (definer, out)
    after = text.replace("\\begin{document}", "\\foo\n\\begin{document}", 1)
    j = after.rindex("\\end{document}") + len("\\end{document}")
    tex.write_text(after[:j] + "\n\\newcommand{\\foo}{}" + after[j:])  # a declaration after the document
    code, out = run(copy)
    assert code == 1 and "has fewer arguments than it takes" in out, out
    tex.write_text(text.replace("\\begin{document}", "\\title{X}\\usepackage[a]{b} $\\frac12 \\bar\\beta \\sqrt[3]{x}$ \\\\ \\{\\}\n"
                                "\\providecommand{\\foo}{\\emph{x}}\\renewcommand*{\\foo}[1][d]{\\sqrt{#1}}\\foo\n"
                                "\\DeclareRobustCommand{\\foo}[1]{#1}\\foo{x}\\newif\\ifdraft\\drafttrue\n"
                                "\\renewcommand{\\foo}[2][d]{}\\foo[abcdefghijk]{x}\\foo[abc]{y}\\foo[abcdefghijk][x]{y}\n\\begin{document}", 1))
    code, out = run(copy)
    assert code == 0, out  # complete calls, single-token, optional and long optional arguments, control symbols, and a body whose call is complete
    tex.write_text(text.replace("\\begin{document}", "a" * 10_000 + "\n\\begin{document}", 1))
    code, out = run(copy)
    assert code == 0, out  # a long plain-letter run must not make uncapped backward scanning quadratic


def test_tex_input_files_are_rejected(copy):
    for name in ("geometry.sty", "article.cls", "t1enc.def"):
        (copy / name).write_text("")
        code, out = run(copy)
        assert code == 1 and f"{name}: a TeX input file" in out, out
        (copy / name).unlink()
    (copy / "sub").mkdir()
    (copy / "sub" / "evil.sty").write_text("")  # a nested input file a source could name by path
    code, out = run(copy)
    assert code == 1 and "sub: a subdirectory" in out, out
    shutil.rmtree(copy / "sub")
    (copy / "empty").mkdir()  # any subdirectory, since one could be filled later
    code, out = run(copy)
    assert code == 1 and "empty: a subdirectory" in out, out
    (copy / "empty").rmdir()
    assert run(copy)[0] == 0
    tex = next(copy.glob("*.tex"))
    text = tex.read_text()
    for loader in ("\\usepackage{sub/evil}", "\\usepackage{../evil}", "\\usepackage{evil.sty}", "\\usepackage[a]{geometry, sub/x}", "\\documentclass{./article}",
                   "\\usepackage{\\foo}", "\\usepackage"):
        tex.write_text(text.replace("\\usepackage{enumitem}", loader + "\n\\usepackage{enumitem}", 1))  # loaders naming paths or nothing plain
        code, out = run(copy)
        assert code == 1 and "does not name plain package or class names" in out, (loader, out)
    tex.write_text(text.replace("\\usepackage{enumitem}", "\\usepackage[margin=1in, a4paper]{geometry}\\usepackage{ amsmath , amssymb }\n\\usepackage\n[x]\n{enumitem}", 1))
    assert run(copy)[0] == 0  # options, comma-separated names and line-broken arguments


def test_truncated_tex_fails(copy):
    tex = next(copy.glob("*.tex"))
    tex.write_text("\\documentclass{article}\n\\begin{document}\nx\n\\end{document}\n")
    code, out = run(copy)
    assert code == 1 and "lines" in out


def test_pdf_truncated_after_header_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(pdf.read_bytes()[:5])
    code, out = run(copy)
    assert code == 1 and "%%EOF" in out


def test_pdf_with_bad_startxref_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = pdf.read_bytes()
    pdf.write_bytes(raw[: raw.rfind(b"startxref")] + b"startxref\n999999999\n%%EOF\n")
    code, out = run(copy)
    assert code == 1 and "startxref" in out


def test_pdf_startxref_at_ordinary_object_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = pdf.read_bytes()
    ordinary = next(m for m in re.finditer(rb"\d+\s+\d+\s+obj\b", raw) if b"/XRef" not in raw[m.start(): m.start() + 4096])
    pdf.write_bytes(raw[: raw.rfind(b"startxref")] + b"startxref\n%d\n%%%%EOF\n" % ordinary.start())
    code, out = run(copy)
    assert code == 1 and "not a cross-reference stream" in out


def test_pdf_last_trailer_is_the_one_checked(copy):
    # an incremental update whose newest trailer is corrupt, with the old valid trailer still in the window
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(pdf.read_bytes() + b"\nstartxref\n999999999\n%%EOF\n")
    code, out = run(copy)
    assert code == 1 and "beyond end of file" in out


def test_pdf_xref_object_without_stream_body_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(
        b"%PDF-1.5\n1 0 obj\n<< /Type /XRef /Size 2 /W [1 2 1] /Root 1 0 R /Length 4 >>\nendobj\nstartxref\n9\n%%EOF\n"
    )
    code, out = run(copy)
    assert code == 1 and "no stream body" in out


MINIMAL_CLASSIC = (
    b"%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\nendobj\n"
    b"xref\n0 2\n0000000000 65535 f \n0000000009 00000 n \n"
    b"trailer\n<< /Size 2 /Root 1 0 R >>\nstartxref\n45\n%%EOF\n"
)


def test_minimal_classic_table_passes(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(classic_pdf())
    code, out = run(copy)
    assert code == 0, out


def test_entryless_classic_table_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(b"%PDF-1.4\nxref\ntrailer\nstartxref\n9\n%%EOF\n")
    code, out = run(copy)
    assert code == 1 and "no entries" in out


def test_empty_xref_stream_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(xref_stream_pdf(b"<< /Type /XRef /Size 2 /W [1 2 1] /Root 1 0 R /Length 0 >>", b""))
    code, out = run(copy)
    assert code == 1 and "not a positive multiple" in out
    pdf.write_bytes(  # without the line ending that must precede endstream it fails earlier
        b"%PDF-1.5\n1 0 obj\n<< /Type /XRef /Size 2 /W [1 2 1] /Root 1 0 R /Length 0 >>\nstream\nendstream\nendobj\nstartxref\n9\n%%EOF\n"
    )
    code, out = run(copy)
    assert code == 1 and "not closed by endstream" in out


def test_corrupted_flate_payload_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = bytearray(pdf.read_bytes())
    i = raw.rfind(b"stream\n", 0, raw.rfind(b"endstream")) + len(b"stream\n") + 40
    raw[i] ^= 0xFF
    pdf.write_bytes(bytes(raw))
    code, out = run(copy)
    assert code == 1 and ("does not inflate" in out or "not a positive multiple" in out)


def xref_stream_pdf(dictionary: bytes, body: bytes) -> bytes:
    return b"%PDF-1.5\n1 0 obj\n" + dictionary + b"\nstream\n" + body + b"\nendstream\nendobj\nstartxref\n9\n%%EOF\n"


def test_indirect_length_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(xref_stream_pdf(b"<< /Type /XRef /Size 1 /W [1 2 1] /Root 1 0 R /Length 4 0 R >>", b"\x01\x00\x09\x00"))
    code, out = run(copy)
    assert code == 1 and "indirect reference" in out


def test_row_count_must_match_size(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(xref_stream_pdf(b"<< /Type /XRef /Size 100 /W [1 2 1] /Root 1 0 R /Length 4 >>", b"\x01\x00\x09\x00"))
    code, out = run(copy)
    assert code == 1 and "declares 100" in out


def test_row_count_must_match_index(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(xref_stream_pdf(b"<< /Type /XRef /Size 5 /Index [0 3] /W [1 2 1] /Root 1 0 R /Length 4 >>", b"\x01\x00\x09\x00"))
    code, out = run(copy)
    assert code == 1 and "declares 3" in out


def test_uncompressed_xref_stream_passes(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(xref_pdf(compress=False))
    code, out = run(copy)
    assert code == 0, out


def test_filter_array_form_is_inflated(copy):
    import zlib

    pdf = next(copy.glob("*.pdf"))
    body = zlib.compress(b"\x01\x00\x09\x00")
    pdf.write_bytes(xref_pdf().replace(b"/Filter /FlateDecode", b"/Filter [/FlateDecode]"))
    code, out = run(copy)
    assert code == 0, out
    bad = xref_stream_pdf(b"<< /Type /XRef /Size 1 /W [1 2 1] /Root 1 0 R /Filter [/LZWDecode] /Length %d >>" % len(body), body)
    pdf.write_bytes(bad)
    code, out = run(copy)
    assert code == 1 and "unsupported" in out


def test_truncated_after_endstream_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = xref_stream_pdf(b"<< /Type /XRef /Size 1 /W [1 2 1] /Root 1 0 R /Length 4 >>", b"\x01\x00\x09\x00")
    pdf.write_bytes(raw.replace(b"\nendobj\n", b"\n"))
    code, out = run(copy)
    assert code == 1 and "endobj" in out


def test_index_ranges_must_fit_size(copy):
    pdf = next(copy.glob("*.pdf"))
    for index in (b"[999 1]", b"[0 1 2]", b"[0 0]"):
        pdf.write_bytes(xref_stream_pdf(b"<< /Type /XRef /Size 1 /Index " + index + b" /W [1 2 1] /Root 1 0 R /Length 4 >>", b"\x01\x00\x09\x00"))
        code, out = run(copy)
        assert code == 1 and "/Index" in out, (index, out)


def test_w_needs_three_fields(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(xref_stream_pdf(b"<< /Type /XRef /Size 1 /W [4] /Root 1 0 R /Length 4 >>", b"\x01\x00\x09\x00"))
    code, out = run(copy)
    assert code == 1 and "exactly three fields" in out


def test_classic_entry_must_point_at_its_object(copy):
    pdf = next(copy.glob("*.pdf"))
    for bad in (b"0000000008 00000 n", b"9999999999 00000 n", b"0000000009 00001 n"):
        pdf.write_bytes(MINIMAL_CLASSIC.replace(b"0000000009 00000 n", bad))
        code, out = run(copy)
        assert code == 1 and "does not point at" in out, (bad, out)


def test_classic_subsection_must_fit_size(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(MINIMAL_CLASSIC.replace(b"/Size 2", b"/Size 1"))
    code, out = run(copy)
    assert code == 1 and "exceeds the trailer /Size" in out


def test_xref_stream_entries_are_dereferenced(copy):
    pdf = next(copy.glob("*.pdf"))
    head = b"<< /Type /XRef /Size 2 /Index [1 1] /W [1 2 1] /Root 1 0 R /Length 4 >>"
    for row, marker in ((b"\x01\xff\xff\x00", "does not point at"), (b"\x01\x00\x08\x00", "does not point at"),
                        (b"\x07\x00\x09\x00", "unknown type"), (b"\x02\x00\x09\x00", "beyond /Size")):
        pdf.write_bytes(xref_stream_pdf(head, row))
        code, out = run(copy)
        assert code == 1 and marker in out, (row, out)


def test_predicted_xref_stream_is_unfiltered(copy):
    import zlib

    pdf = next(copy.glob("*.pdf"))
    # PNG Up predictor: one row, filter byte 2, row bytes are deltas against a zero previous row
    pdf.write_bytes(xref_pdf(predictor=True, dict_extra=b"/DecodeParms << /Columns 4 /Predictor 12 >> "))
    code, out = run(copy)
    assert code == 0, out


def test_bogus_prev_chain_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(classic_pdf(extra_trailer=b"/Prev 999999 "))
    code, out = run(copy)
    assert code == 1 and "links forward" in out, out  # a forward /Prev is rejected before it is followed


def test_cyclic_prev_chain_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf(extra_trailer=b"/Prev 000000 ")
    xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    pdf.write_bytes(raw.replace(b"/Prev 000000 ", b"/Prev %06d " % xref))
    code, out = run(copy)
    assert code == 1 and "links forward" in out, out  # a self-pointing /Prev is not an earlier section


def test_incremental_update_extent_comes_from_prev_section(copy):
    # an update section rewriting only object 1; /Size 4 is justified by the original section
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf()
    old_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    o1 = len(raw)
    raw += b"1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n"
    new_xref = len(raw)
    raw += b"xref\n1 1\n%010d 00000 n \ntrailer\n<< /Size 4 /Root 1 0 R /Prev %d >>\nstartxref\n%d\n%%%%EOF\n" % (o1, old_xref, new_xref)
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 0, out


def classic_with_free_4(head=b"0000000004 65535 f ", tail=b"0000000000 00000 f "):
    """objects 1-3 in use, object 4 free and linked from object 0, /Size 5."""
    return classic_pdf(edit=lambda b: b.replace(b"xref\n0 4\n0000000000 65535 f ", b"xref\n0 5\n" + head)
                       .replace(b"trailer", tail + b"\ntrailer").replace(b"/Size 4 ", b"/Size 5 "))


def test_free_top_entry_passes_classic(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(classic_with_free_4())
    code, out = run(copy)
    assert code == 0, out


def test_free_top_entry_passes_xref_stream(copy):
    pdf = next(copy.glob("*.pdf"))
    rows = lambda t, o1, o2, o3: [b"\x00\x00\x05\xff", *t[1:], b"\x00\x00\x00\x00"]
    pdf.write_bytes(xref_pdf(rows=rows).replace(b"/Size 5 ", b"/Size 6 "))
    code, out = run(copy)
    assert code == 0, out


def test_free_entry_pointer_must_be_below_size(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(classic_pdf(edit=lambda b: b.replace(b"0000000000 65535 f", b"9999999999 65535 f")))
    code, out = run(copy)
    assert code == 1 and "beyond /Size" in out, out
    pdf.write_bytes(xref_pdf(rows=lambda t, o1, o2, o3: [b"\x00\x00\x63\xff", *t[1:]]))
    code, out = run(copy)
    assert code == 1 and "beyond /Size" in out, out


def test_object_zero_must_be_free_with_generation_65535(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(classic_pdf(edit=lambda b: b.replace(b"0000000000 65535 f", b"0000000000 00000 f")))
    code, out = run(copy)
    assert code == 1 and "not 65535" in out, out


def test_stream_generation_is_taken_literally(copy):
    pdf = next(copy.glob("*.pdf"))
    # a two-byte column holding exactly 65535 passes; a three-byte column holding 65536 fails
    pdf.write_bytes(xref_pdf(gen_bytes=2))
    code, out = run(copy)
    assert code == 0, out
    pdf.write_bytes(xref_pdf(gen_bytes=3, rows=lambda t, o1, o2, o3: [b"\x00\x00\x00\x01\x00\x00", *t[1:]]))
    code, out = run(copy)
    assert code == 1 and "generation 65536 > 65535" in out, out


def test_unlinked_stream_free_entry_passes(copy):
    # object 5 free with next-free field 0 and not linked from object 0: allowed in a stream
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(xref_pdf(rows=lambda t, o1, o2, o3: [*t, b"\x00\x00\x00\x00"]).replace(b"/Size 5 ", b"/Size 6 "))
    code, out = run(copy)
    assert code == 0, out
    # but an unlinked free entry pointing at object 3 dangles
    pdf.write_bytes(xref_pdf(rows=lambda t, o1, o2, o3: [*t, b"\x00\x00\x03\x00"]).replace(b"/Size 5 ", b"/Size 6 "))
    code, out = run(copy)
    assert code == 1 and "not on the free list" in out, out


def test_free_entries_must_form_the_free_list(copy):
    pdf = next(copy.glob("*.pdf"))
    # object 4 free but object 0 still points at 0: object 4 is off the list
    pdf.write_bytes(classic_with_free_4(head=b"0000000000 65535 f "))
    code, out = run(copy)
    assert code == 1 and "not on the free list" in out, out
    # object 0 points at the in-use object 2
    pdf.write_bytes(classic_with_free_4(head=b"0000000002 65535 f "))
    code, out = run(copy)
    assert code == 1 and "not an unvisited free entry" in out, out


def test_classic_free_list_is_judged_at_its_own_section(copy):
    # a newer cross-reference stream replaces object 0 with an unlinked row and inherits the
    # classic section's free object 4 through /Prev; the classic list was valid at its section
    pdf = next(copy.glob("*.pdf"))
    raw = classic_with_free_4()
    old_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    o5 = len(raw)
    rows = b"\x00\x00\x00\xff" + b"\x01" + o5.to_bytes(2, "big") + b"\x00"
    raw += (b"5 0 obj\n<< /Type /XRef /Size 6 /Index [0 1 5 1] /W [1 2 1] /Root 1 0 R /Prev %d /Length %d >>\nstream\n"
            % (old_xref, len(rows)) + rows + b"\nendstream\nendobj\nstartxref\n%d\n%%%%EOF\n" % o5)
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 0, out


def test_huge_declared_row_count_fails_fast(copy):
    pdf = next(copy.glob("*.pdf"))
    for dictionary in (b"<< /Type /XRef /Size 1000000000 /W [1 2 1] /Root 1 0 R /Length 4 >>",
                       b"<< /Type /XRef /Size 1000000001 /Index [0 1000000000] /W [1 2 1] /Root 1 0 R /Length 4 >>"):
        pdf.write_bytes(xref_stream_pdf(dictionary, b"\x01\x00\x09\x00"))
        code, out = run(copy)
        assert code == 1 and "declares 1000000000" in out, out


def test_in_use_generation_is_bounded(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(classic_pdf(edit=lambda b: b.replace(b"0000000009 00000 n", b"0000000009 65536 n")))
    code, out = run(copy)
    assert code == 1 and "generation 65536 > 65535" in out, out
    row1 = lambda t, o1, o2, o3: [b"\x00\x00\x00\x00\xff\xff", b"\x01" + o1.to_bytes(2, "big") + b"\x01\x00\x00", *t[2:]]
    pdf.write_bytes(xref_pdf(gen_bytes=3, rows=row1))
    code, out = run(copy)
    assert code == 1 and "generation 65536 > 65535" in out, out


def test_matching_compression_bomb_hits_the_row_ceiling(copy):
    import zlib
    pdf = next(copy.glob("*.pdf"))
    # two million all-zero rows agree with the declaration and compress to a few kilobytes
    body = zlib.compress(bytes(4 * 2_000_000))
    pdf.write_bytes(xref_stream_pdf(b"<< /Type /XRef /Size 2000000 /W [1 2 1] /Root 1 0 R /Filter /FlateDecode /Length %d >>" % len(body), body))
    code, out = run(copy)
    assert code == 1 and "above the ceiling" in out, out


def hybrid_pdf(free5=b"\x00\x00\x00\x00", companion_extra=b"", free4=False):
    """A classic table for objects 0-3 whose trailer names a companion /XRefStm stream
    (object 4) describing itself and a free object 5; /Size 6.  With ``free4`` the classic
    table also lists object 4 as free (on the free list from object 0)."""
    raw = classic_pdf()
    raw = raw[:int(re.search(rb"startxref\n(\d+)", raw).group(1))]  # the objects only: one revision, one table
    o4 = len(raw)
    rows = b"\x00\x00\x00\xff" + b"\x01" + o4.to_bytes(2, "big") + b"\x00" + free5
    raw += (b"4 0 obj\n<< /Type /XRef /Size 6 /Index [0 1 4 2] /W [1 2 1] /Root 1 0 R " + companion_extra + b"/Length %d >>\nstream\n" % len(rows)
            + rows + b"\nendstream\nendobj\n")
    xref = len(raw)
    head, tail = (b"0 5\n0000000004 65535 f \n", b"0000000000 00000 f \n") if free4 else (b"0 4\n0000000000 65535 f \n", b"")
    raw += (b"xref\n" + head + b"".join(b"%010d 00000 n \n" % int(m) for m in re.findall(rb"(\d{10}) 00000 n", classic_pdf())) + tail
            + b"trailer\n<< /Size 6 /Root 1 0 R /XRefStm %d >>\nstartxref\n%d\n%%%%EOF\n" % (o4, xref))
    return raw


def test_hybrid_companion_stream_is_walked(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(hybrid_pdf())
    code, out = run(copy)
    assert code == 0, out
    # the companion's free row for object 5 points beyond /Size
    pdf.write_bytes(hybrid_pdf(free5=b"\x00\x00\x63\x00"))
    code, out = run(copy)
    assert code == 1 and "/XRefStm" in out and "beyond /Size" in out, out


def test_classic_table_cannot_free_its_companion_stream(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(hybrid_pdf(free4=True))  # the companion lists itself, the table frees it, free list 0 -> 4 -> 0
    code, out = run(copy)
    assert code == 1 and "companion object 4 0" in out and "classic table's entries take precedence" in out, out


def test_companion_stream_size_is_checked(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(hybrid_pdf().replace(b"/XRef /Size 6", b"/XRef /Size 7"))
    code, out = run(copy)
    assert code == 1 and "/Size 7 is not one more than the highest object number 5" in out, out


def test_historical_entry_cannot_point_into_a_later_revision(copy):
    # the original section's entry for object 3 is redirected to the copy of object 3 that
    # a later update appends; the header matches, but that object postdates the section
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf()
    old_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    old_o3 = re.findall(rb"(\d{10}) 00000 n", raw)[2]
    new_o3 = len(raw)
    raw += b"3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 20 20] >>\nendobj\n"
    new_xref = len(raw)
    raw += b"xref\n3 1\n%010d 00000 n \ntrailer\n<< /Size 4 /Root 1 0 R /Prev %d >>\nstartxref\n%d\n%%%%EOF\n" % (new_o3, old_xref, new_xref)
    pdf.write_bytes(raw)
    assert run(copy)[0] == 0
    pdf.write_bytes(raw.replace(old_o3 + b" 00000 n", b"%010d 00000 n" % new_o3, 1))
    code, out = run(copy)
    assert code == 1 and "not before its cross-reference section" in out, out


def test_classic_entry_cannot_point_into_its_own_trailer(copy):
    # the trailer carries the text "3 0 obj"; the original entry for object 3 is redirected
    # there, and a later update supersedes object 3 so pypdf never dereferences the old entry
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf(extra_trailer=b"/Note (3 0 obj) ")
    old_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    old_o3 = re.findall(rb"(\d{10}) 00000 n", raw)[2]
    embedded = raw.index(b"3 0 obj", old_xref)
    new_o3 = len(raw)
    raw += b"3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 20 20] >>\nendobj\n"
    new_xref = len(raw)
    raw += b"xref\n3 1\n%010d 00000 n \ntrailer\n<< /Size 4 /Root 1 0 R /Prev %d >>\nstartxref\n%d\n%%%%EOF\n" % (new_o3, old_xref, new_xref)
    pdf.write_bytes(raw.replace(old_o3 + b" 00000 n", b"%010d 00000 n" % embedded, 1))
    code, out = run(copy)
    assert code == 1 and "not before its cross-reference section" in out, out


def flate_stream(payload: bytes, extra: bytes = b"") -> bytes:
    import zlib
    content = zlib.compress(payload)
    return b"<< /Length %d /Filter /FlateDecode " % len(content) + extra + b">>\nstream\n" + content + b"\nendstream"


def superseded_pdf(old: bytes) -> bytes:
    """Object 4 is the stream ``old`` in the original revision and a sound content stream in
    an update, so pypdf reads only the update while the guard must still inspect ``old``."""
    raw = classic_pdf(objs=[b"<< /Type /Catalog /Pages 2 0 R >>", b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
                            b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] /Contents 4 0 R >>", old])
    old_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    new_o4 = len(raw)
    raw += b"4 0 obj\n" + flate_stream(b"0 0 m 10 10 l S") + b"\nendobj\n"
    new_xref = len(raw)
    return raw + b"xref\n4 1\n%010d 00000 n \ntrailer\n<< /Size 5 /Root 1 0 R /Prev %d >>\nstartxref\n%d\n%%%%EOF\n" % (new_o4, old_xref, new_xref)


def test_superseded_stream_is_still_decoded(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = superseded_pdf(flate_stream(b"0 0 m 10 10 l S"))
    pdf.write_bytes(raw)
    assert run(copy)[0] == 0
    # flip a byte inside the superseded copy of the stream (the first one in the file)
    i = raw.index(b"stream\n") + len(b"stream\n") + 4
    pdf.write_bytes(raw[:i] + bytes([raw[i] ^ 0xFF]) + raw[i + 1:])
    code, out = run(copy)
    assert code == 1 and "superseded stream object 4 does not inflate" in out, out


def test_superseded_stream_filter_must_parse(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(flate_stream(b"x").replace(b"/Filter /FlateDecode", b"/Filter 9 0 R")))
    code, out = run(copy)
    assert code == 1 and "unparsable /Filter" in out, out


def test_superseded_stream_decode_parms_are_validated(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(flate_stream(b"\x00abcd", b"/DecodeParms << /Predictor 12 /Columns 4 >> ")))
    assert run(copy)[0] == 0
    for parms, message in ((b"/DecodeParms << /Predictor 99 >> ", "unsupported /Predictor 99"),
                           (b"/DecodeParms << /Predictor 12 /Columns 999 >> ", "not a multiple of the predicted row width"),
                           (b"/DecodeParms 7 0 R ", "not a direct dictionary")):
        pdf.write_bytes(superseded_pdf(flate_stream(b"\x00abcd", parms)))
        code, out = run(copy)
        assert code == 1 and message in out, (parms, out)


def test_tiff_predictor_geometry_is_validated(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(flate_stream(b"abcdefgh", b"/DecodeParms << /Predictor 2 /Columns 4 >> ")))
    assert run(copy)[0] == 0
    pdf.write_bytes(superseded_pdf(flate_stream(b"x", b"/DecodeParms << /Predictor 2 /Columns 999 >> ")))
    code, out = run(copy)
    assert code == 1 and "not a multiple of the predicted row width 999" in out, out


def test_superseded_object_with_malformed_stream_keyword_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(flate_stream(b"x").replace(b">>\nstream\n", b">>\nstreaX\n")))
    code, out = run(copy)
    assert code == 1 and "not one complete object closed by endobj" in out, out


def test_filter_names_are_parsed_whole(copy):
    pdf = next(copy.glob("*.pdf"))
    # /FlateDecode#58 is the name /FlateDecodeX; a truncated escape is not a name at all
    pdf.write_bytes(superseded_pdf(flate_stream(b"x").replace(b"/FlateDecode", b"/FlateDecode#58")))
    code, out = run(copy)
    assert code == 1 and "unsupported filter chain" in out, out
    pdf.write_bytes(superseded_pdf(flate_stream(b"x").replace(b"/FlateDecode", b"/FlateDecode#5")))
    code, out = run(copy)
    assert code == 1 and "not one complete object" in out, out  # the truncated escape breaks the dictionary itself
    pdf.write_bytes(xref_pdf().replace(b"/Filter /FlateDecode", b"/Filter /FlateDecode#58"))
    code, out = run(copy)
    assert code == 1 and "unsupported cross-reference stream filter chain" in out, out
    pdf.write_bytes(xref_pdf().replace(b"/Filter /FlateDecode", b"/Filter /Flate#44ecode"))
    assert run(copy)[0] == 0


def objstm_pdf(container=4, index=0, member=5, body=b"<< /Foo 1 >>", members=None, predictor=None, row5=None, png=None, eol=b"\n"):
    """Objects 1-3 as usual, object 4 an uncompressed object stream whose header lists
    ``members`` (default one member, ``member``, at offset 0) before ``body``, object 6
    the cross-reference stream; object 5's row names ``container`` at ``index``, any
    further member object number gets a type-2 row into object 4; /Size covers them."""
    out = b"%PDF-1.5\n"
    offs = {}
    for n, obj in ((1, b"<< /Type /Catalog /Pages 2 0 R >>"), (2, b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>"),
                   (3, b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>")):
        offs[n] = len(out)
        out += b"%d 0 obj\n%s\nendobj\n" % (n, obj)
    members = [(member, 0)] if members is None else members
    header = b"".join(b"%d %d " % pair for pair in members)
    data = header + body
    payload, extra = data, b""
    if png:  # one PNG row under the Sub filter, encoded with ``bpp`` bytes per pixel, declaring ``colors`` components
        import zlib
        bpp, colors = png
        data += b" " * (-len(data) % colors)
        enc = bytes((data[j] - (data[j - bpp] if j >= bpp else 0)) & 0xFF for j in range(len(data)))
        payload = zlib.compress(b"\x01" + enc)
        extra = b"/Filter /FlateDecode /DecodeParms << /Predictor 11 /Colors %d /Columns %d >> " % (colors, len(data) // colors)
    elif predictor == 12:  # one PNG row with the Up filter; the zero previous row leaves the bytes unchanged
        import zlib
        payload = zlib.compress(b"\x02" + data)
        extra = b"/Filter /FlateDecode /DecodeParms << /Predictor 12 /Columns %d >> " % len(data)
    elif predictor == 2:  # one TIFF row of horizontal differences
        import zlib
        payload = zlib.compress(bytes([data[0]] + [(data[i] - data[i - 1]) & 0xFF for i in range(1, len(data))]))
        extra = b"/Filter /FlateDecode /DecodeParms << /Predictor 2 /Columns %d >> " % len(data)
    offs[4] = len(out)
    out += b"4 0 obj\n<< /Type /ObjStm /N %d /First %d " % (len(members), len(header)) + extra + b"/Length %d >>\nstream\n" % len(payload) + payload + eol + b"endstream\nendobj\n"
    offs[6] = len(out)
    extra = {num: k for k, (num, _) in enumerate(members) if num not in (0, 1, 2, 3, 4, 5, 6)}
    size = max([7] + [num + 1 for num in extra])
    row = lambda kind, a, b: bytes([kind]) + a.to_bytes(2, "big") + bytes([b])
    rows = b""
    for num in range(size):
        if num == 0:
            rows += row(0, 0, 255)
        elif num in offs:
            rows += row(1, offs[num], 0)
        elif num == 5:
            rows += row5 if row5 is not None else row(2, container, index)
        elif num in extra:
            rows += row(2, 4, extra[num])
        else:
            rows += row(0, 0, 0)
    out += b"6 0 obj\n<< /Type /XRef /Size %d /W [1 2 1] /Root 1 0 R /Length %d >>\nstream\n" % (size, len(rows)) + rows
    return out + b"\nendstream\nendobj\nstartxref\n%d\n%%%%EOF\n" % offs[6]


def test_type2_entries_resolve_against_their_revision(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(objstm_pdf())
    assert run(copy)[0] == 0
    pdf.write_bytes(objstm_pdf(index=1))
    code, out = run(copy)
    assert code == 1 and "index 1 beyond /N 1" in out, out
    raw = objstm_pdf(container=2)
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 1 and "not an object stream" in out, out
    # a later classic update supplies object 5 in use, so pypdf never resolves the old row
    old_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    o5 = len(raw)
    raw += b"5 0 obj\n<< /Foo 2 >>\nendobj\n"
    new_xref = len(raw)
    raw += b"xref\n5 1\n%010d 00000 n \ntrailer\n<< /Size 7 /Root 1 0 R /Prev %d >>\nstartxref\n%d\n%%%%EOF\n" % (o5, old_xref, new_xref)
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 1 and "not an object stream" in out, out


def test_type2_member_must_be_the_referenced_object(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = objstm_pdf(member=9)
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 1 and "member 0 of object stream 4 is object 9" in out, out
    old_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    o5 = len(raw)
    raw += b"5 0 obj\n<< /Foo 2 >>\nendobj\n"
    new_xref = len(raw)
    raw += b"xref\n5 1\n%010d 00000 n \ntrailer\n<< /Size 7 /Root 1 0 R /Prev %d >>\nstartxref\n%d\n%%%%EOF\n" % (o5, old_xref, new_xref)
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 1 and "member 0 of object stream 4 is object 9" in out, out


def classic_update(raw: bytes, num: int, body: bytes, size: int) -> bytes:
    """Append a classic incremental update that supplies object ``num`` with ``body``."""
    old_xref = int(re.findall(rb"startxref\n(\d+)", raw)[-1])
    off = len(raw)
    raw += b"%d 0 obj\n%s\nendobj\n" % (num, body)
    new_xref = len(raw)
    return raw + b"xref\n%d 1\n%010d 00000 n \ntrailer\n<< /Size %d /Root 1 0 R /Prev %d >>\nstartxref\n%d\n%%%%EOF\n" % (num, off, size, old_xref, new_xref)


def test_compressed_members_are_parsed(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = objstm_pdf(body=b"not-a-object")
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 1 and "member 0 of object stream 4 is not one complete object" in out, out
    pdf.write_bytes(classic_update(raw, 5, b"<< /Foo 2 >>", 7))
    code, out = run(copy)
    assert code == 1 and "member 0 of object stream 4 is not one complete object" in out, out


def test_catalog_type_must_be_top_level(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf(objs=[b"<< /Pages 2 0 R /Foo << /Type /Catalog >> >>", b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
                            b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>"])
    pdf.write_bytes(classic_update(raw, 1, b"<< /Type /Catalog /Pages 2 0 R >>", 4))
    code, out = run(copy)
    assert code == 1 and "top-level /Type is /Catalog" in out, out


def test_inherited_type2_rows_are_revalidated_after_container_replacement(copy):
    pdf = next(copy.glob("*.pdf"))
    data = b"9 0 << /Foo 3 >>"
    replacement = b"<< /Type /ObjStm /N 1 /First 4 /Length %d >>\nstream\n" % len(data) + data + b"\nendstream"
    raw = classic_update(objstm_pdf(), 4, replacement, 7)  # object 5's inherited row now indexes a member that is object 9
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 1 and "member 0 of object stream 4 is object 9" in out, out
    pdf.write_bytes(classic_update(raw, 5, b"<< /Foo 2 >>", 7))  # a third revision supplies object 5 directly
    code, out = run(copy)
    assert code == 1 and "member 0 of object stream 4 is object 9" in out, out


def test_trailer_keys_are_read_from_the_top_level(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf(edit=lambda b: b.replace(b"/Root 1 0 R ", b"/Foo << /Root 1 0 R >> "))
    pdf.write_bytes(classic_update(raw, 3, b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>", 4))
    code, out = run(copy)
    assert code == 1 and "trailer dictionary lacks /Size or /Root" in out, out
    pdf.write_bytes(xref_pdf().replace(b"/Root 1 0 R ", b"/Foo << /Root 1 0 R >> "))
    code, out = run(copy)
    assert code == 1 and "cross-reference stream lacks /Size or /Root" in out, out


def test_object_stream_member_offsets_must_increase(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(objstm_pdf(members=[(5, 0), (7, 13)], body=b"<< /Foo 1 >> << /Bar 2 >>"))
    assert run(copy)[0] == 0
    pdf.write_bytes(objstm_pdf(members=[(5, 0), (7, 0)]))
    code, out = run(copy)
    assert code == 1 and "member offsets are not strictly increasing" in out, out


def test_superseded_stream_length_is_read_from_the_top_level(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(b"<< /Foo << /Length 1 >> >>\nstream\nx\nendstream"))
    code, out = run(copy)
    assert code == 1 and "lacks a direct /Length" in out, out
    import zlib
    content = zlib.compress(b"x")
    pdf.write_bytes(superseded_pdf(b"<< /Length 1.5 /Filter /FlateDecode >>\nstream\n" + content + b"\nendstream"))
    code, out = run(copy)
    assert code == 1 and "lacks a direct /Length" in out, out


def test_predicted_object_streams_are_unpredicted_before_parsing(copy):
    pdf = next(copy.glob("*.pdf"))
    for predictor in (12, 2):
        pdf.write_bytes(objstm_pdf(predictor=predictor))
        code, out = run(copy)
        assert code == 0, (predictor, out)


def test_index_ranges_must_be_ordered_and_disjoint(copy):
    pdf = next(copy.glob("*.pdf"))
    rows = b"\x01\x00\x09\x00" * 4
    for index in (b"[0 3 1 1]", b"[2 1 0 2]"):
        pdf.write_bytes(xref_stream_pdf(b"<< /Type /XRef /Size 3 /Index " + index + b" /W [1 2 1] /Root 1 0 R /Length 16 >>", rows))
        code, out = run(copy)
        assert code == 1 and "overlap or are not in increasing order" in out, (index, out)


def test_duplicate_dictionary_keys_fail(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(b"<< /Length 1 /Length 1 >>\nstream\nx\nendstream"))
    code, out = run(copy)
    assert code == 1 and "not one complete object" in out, out


def test_prev_must_point_backwards(copy):
    # the final startxref names section A, whose /Prev points forward at section B
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf(extra_trailer=b"/Prev 0000000000 ")
    a_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    raw = raw[:raw.rfind(b"startxref")]
    o3 = len(raw)
    raw += b"3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 20 20] >>\nendobj\n"
    b_xref = len(raw)
    raw += b"xref\n3 1\n%010d 00000 n \ntrailer\n<< /Size 4 /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % (o3, a_xref)
    pdf.write_bytes(raw.replace(b"/Prev 0000000000 ", b"/Prev %010d " % b_xref))
    code, out = run(copy)
    assert code == 1 and "links forward" in out, out


def test_overlapping_classic_subsections_fail(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(classic_pdf(edit=lambda b: b.replace(b"trailer", b"1 1\n0000000009 00000 n \ntrailer")))
    code, out = run(copy)
    assert code == 1 and "overlaps an earlier subsection" in out, out


def test_companion_prev_is_validated(copy):
    pdf = next(copy.glob("*.pdf"))
    for extra in (b"/Prev 999999 ", b"/Prev 0 "):
        pdf.write_bytes(hybrid_pdf(companion_extra=extra))
        code, out = run(copy)
        assert code == 1 and "not the trailer's earlier /Prev" in out, (extra, out)


def test_object_stream_member_numbers_must_be_unique(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(objstm_pdf(members=[(5, 0), (5, 13)], body=b"<< /Foo 1 >> << /Bar 2 >>"))
    code, out = run(copy)
    assert code == 1 and "repeats an object number" in out, out


def test_historical_page_tree_is_walked(copy):
    pdf = next(copy.glob("*.pdf"))
    pages, page = b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>", b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>"
    for catalog, message in ((b"<< /Type /Catalog /Pages 9 0 R >>", "page tree: object 9 0 R is not in use"),
                             (b"<< /Type /Catalog /Pages 3 0 R >>", "carries a /Parent"),
                             (b"<< /Type /Catalog >>", "lacks a /Pages reference")):
        raw = classic_pdf(objs=[catalog, pages, page])
        pdf.write_bytes(classic_update(raw, 1, b"<< /Type /Catalog /Pages 2 0 R >>", 4))  # pypdf reads only the repaired catalog
        code, out = run(copy)
        assert code == 1 and message in out, (catalog, out)
    raw = classic_pdf(objs=[b"<< /Type /Catalog /Pages 2 0 R >>", b"<< /Type /Pages /Kids [3 0 R] /Count 2 >>", page])
    pdf.write_bytes(classic_update(raw, 2, pages, 4))
    code, out = run(copy)
    assert code == 1 and "declares /Count 2 but holds 1" in out, out


def test_every_object_stream_member_needs_a_type2_entry(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(objstm_pdf(members=[(5, 0), (4, 13)], body=b"<< /Foo 1 >> << /Bar 2 >>"))
    code, out = run(copy)
    assert code == 1 and "no matching type-2 entry" in out, out


def test_every_revision_must_end_with_its_terminator(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf()
    old_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    raw = raw[:raw.rfind(b"startxref")]  # the original revision loses its startxref and %%EOF
    o3 = len(raw)
    raw += b"3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 20 20] >>\nendobj\n"
    new_xref = len(raw)
    raw += b"xref\n3 1\n%010d 00000 n \ntrailer\n<< /Size 4 /Root 1 0 R /Prev %d >>\nstartxref\n%d\n%%%%EOF\n" % (o3, old_xref, new_xref)
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 1 and "never a complete file" in out, out


def test_page_tree_root_carries_no_parent(copy):
    pdf = next(copy.glob("*.pdf"))
    page = b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>"
    raw = classic_pdf(objs=[b"<< /Type /Catalog /Pages 2 0 R >>", b"<< /Type /Pages /Kids [3 0 R] /Count 1 /Parent 1 0 R >>", page])
    pdf.write_bytes(classic_update(raw, 2, b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>", 4))
    code, out = run(copy)
    assert code == 1 and "carries a /Parent" in out, out


def test_stream_objects_cannot_serve_as_tree_nodes(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf(objs=[b"<< /Type /Catalog /Pages 2 0 R /Length 1 >>\nstream\nx\nendstream", b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
                            b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>"])
    pdf.write_bytes(classic_update(raw, 1, b"<< /Type /Catalog /Pages 2 0 R >>", 4))
    code, out = run(copy)
    assert code == 1 and "is a stream or is not closed by endobj" in out, out


def test_unreferenced_object_streams_are_still_decoded(copy):
    # object 5's row becomes a free entry, so nothing names object stream 4, whose header still declares object 5
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(objstm_pdf(row5=b"\x00\x00\x00\x00"))
    code, out = run(copy)
    assert code == 1 and "no matching type-2 entry" in out, out


def test_symbolic_links_are_rejected(copy):
    pdf = next(copy.glob("*.pdf"))
    target = SRC / pdf.name  # the repository's own PDF, outside the checked directory
    pdf.unlink()
    pdf.symlink_to(target)
    code, out = run(copy)
    assert code == 1 and "required by the manifest but a symbolic link" in out, out
    pdf.unlink()
    shutil.copy(target, pdf)
    (copy / "alias.pdf").symlink_to(pdf)  # a link inside the directory is not a source either
    code, out = run(copy)
    assert code == 1 and "alias.pdf: a symbolic link" in out, out
    (copy / "alias.pdf").unlink()
    (copy / "MANIFEST").rename(copy / "MANIFEST.real")
    (copy / "MANIFEST").symlink_to(copy / "MANIFEST.real")
    code, out = run(copy)
    assert code == 1 and "manifest of required files is a symbolic link" in out, out


def test_symbolic_link_to_the_directory_is_rejected(copy):
    link = copy.parent / "linked"
    link.symlink_to(copy)
    code, out = run(link)
    assert code == 1 and "the manuscripts directory is a symbolic link" in out, out
    assert run(copy)[0] == 0  # the real directory still passes


def test_manifest_entries_must_be_bare_names(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.unlink()
    manifest = copy / "MANIFEST"
    lines = manifest.read_text().splitlines()
    for entry in ("../archive/2026-09-08/README_READ_FIRST_2026_09_08.pdf", "/etc/hostname", "sub/dir.pdf"):
        manifest.write_text("\n".join(l if not l.endswith(".pdf") else entry for l in lines) + "\n")
        code, out = run(copy)
        assert code == 1 and "not a bare file name" in out, (entry, out)


def test_eof_marker_needs_a_line_boundary(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(classic_update(classic_pdf().replace(b"%%EOF\n", b"%%EOFX\n"), 3, b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 20 20] >>", 4))
    code, out = run(copy)
    assert code == 1 and "never a complete file" in out, out
    pdf.write_bytes(classic_pdf() + b"X")
    code, out = run(copy)
    assert code == 1 and "does not end with %%EOF" in out, out
    terminator = re.search(rb"startxref\n\d+\n%%EOF\n", classic_pdf()).group()
    for extra in (terminator, b"stray bytes\n" + terminator):  # a duplicate terminator naming the same section
        pdf.write_bytes(classic_pdf() + extra)
        code, out = run(copy)
        assert code == 1 and "bytes follow the newest revision's %%EOF" in out, out
    pdf.write_bytes(classic_pdf() + b"\r\n\n")
    assert run(copy)[0] == 0  # trailing line endings only


def test_superseded_dictionary_is_parsed_structurally(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(b"<< /A [1 2 R] /B << /C (x) >> /D <41> /E true /F#20G null >>"))
    assert run(copy)[0] == 0
    for body in (b"<< /Type >>", b"<< garbage >>", b"<< /A 1 /B >>", b"<< 1 2 >>"):
        pdf.write_bytes(superseded_pdf(body))
        code, out = run(copy)
        assert code == 1 and "not one complete object" in out, (body, out)


def test_historical_trailer_root_is_resolved(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = superseded_pdf(flate_stream(b"x"))
    for root, message in ((b"/Root 9 0 R", "is not in use"), (b"/Root 2 0 R", "top-level /Type is /Catalog"),
                          (b"/Root 1 1 R", "has generation 0")):
        pdf.write_bytes(raw.replace(b"/Root 1 0 R", root, 1))
        code, out = run(copy)
        assert code == 1 and message in out, (root, out)


def test_malformed_predictor_values_fail(copy):
    pdf = next(copy.glob("*.pdf"))
    for parms in (b"/DecodeParms << /Predictor /Bogus >> ", b"/DecodeParms << /Predictor 2 /Columns -1 >> "):
        pdf.write_bytes(superseded_pdf(flate_stream(b"x", parms)))
        code, out = run(copy)
        assert code == 1 and "malformed predictor parameter value" in out, (parms, out)


def test_lexer_uses_the_pdf_white_space_set(copy):
    assert b"\\s" not in SCRIPT.read_bytes()  # every pattern spells out the six PDF white-space bytes
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(b"<< /Bad\x00Name 1 >>"))  # NUL is white space: /Bad, then a bare word
    code, out = run(copy)
    assert code == 1 and "not one complete object" in out, out
    pdf.write_bytes(superseded_pdf(b"<<\x00/A\x001\x0c/B\x0b 2 >>"))  # NUL and form feed separate; vertical tab is a name byte
    assert run(copy)[0] == 0
    pdf.write_bytes(superseded_pdf(b"<< /A 1\x0b >>"))  # 1\x0b is not a number
    code, out = run(copy)
    assert code == 1 and "not one complete object" in out, out


def test_superseded_non_dictionary_object_is_parsed(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(b"[1 2 R (a (nested) string) /Name#20x 3.5 <414243> true null]"))
    assert run(copy)[0] == 0
    pdf.write_bytes(superseded_pdf(b"not-a-PDF-object"))
    code, out = run(copy)
    assert code == 1 and "not one complete object" in out, out
    pdf.write_bytes(superseded_pdf(b"[1 2"))
    code, out = run(copy)
    assert code == 1 and "not one complete object" in out, out


def test_historical_objects_close_before_their_section(copy):
    pdf = next(copy.glob("*.pdf"))
    # the original object 4 is an unterminated string; the only closing parenthesis, and an
    # endobj, sit in a comment appended after the update's own object, past the original %%EOF
    raw = superseded_pdf(b"(open")
    marker = b"\nendobj\nxref\n4 1\n"
    patched = raw.replace(marker, b"\nendobj\n% ) endobj\nxref\n4 1\n")
    old_xref = int(re.findall(rb"startxref\n(\d+)", raw)[-1])
    patched = patched.replace(b"startxref\n%d\n" % old_xref, b"startxref\n%d\n" % (old_xref + len(b"% ) endobj\n")))
    pdf.write_bytes(patched)
    code, out = run(copy)
    assert code == 1 and "object 4 is not one complete object" in out and "before its cross-reference section" in out, out


def test_revision_terminators_are_line_delimited(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf()
    xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    updated = classic_update(raw, 3, b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 20 20] >>", 4)
    one_line = updated.replace(b"startxref\n%d\n%%%%EOF\n" % xref, b"startxref %d %%%%EOF\n" % xref, 1)  # same length
    assert one_line != updated
    pdf.write_bytes(one_line)
    code, out = run(copy)
    assert code == 1 and "on separate lines" in out, out
    pdf.write_bytes(updated.replace(b"startxref\n%d\n%%%%EOF\n" % xref, b"startxref\r%d\r%%%%EOF\r" % xref, 1))  # CR endings, same length
    assert run(copy)[0] == 0
    pdf.write_bytes(raw.replace(b"startxref\n%d\n%%%%EOF\n" % xref, b"startxref %d\n%%%%EOF\n" % xref))  # the final terminator too
    code, out = run(copy)
    assert code == 1, out


def test_endobj_needs_a_token_boundary(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = superseded_pdf(b"<< /Marker 1 >>")
    assert raw.count(b"/Marker 1 >>\nendobj\n") == 1
    pdf.write_bytes(raw.replace(b"/Marker 1 >>\nendobj\n", b"/Marker 1 >>\nendobj\x0b"))  # vertical tab is a regular byte
    code, out = run(copy)
    assert code == 1 and "not one complete object closed by endobj" in out, out


def insert_before_xref(raw: bytes, extra: bytes) -> bytes:
    """``raw`` with ``extra`` inserted just before its (only) cross-reference section."""
    xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    return raw[:xref] + extra + raw[xref:].replace(b"startxref\n%d\n" % xref, b"startxref\n%d\n" % (xref + len(extra)))


def test_unlisted_objects_are_rejected(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(insert_before_xref(classic_pdf(), b"99 0 obj\nnot-a-PDF-object\nendobj\n"))  # /Size 4 and the rows unchanged
    code, out = run(copy)
    assert code == 1 and "not accounted for by any cross-reference entry" in out, out
    pdf.write_bytes(insert_before_xref(classic_pdf(), b"garbage\n"))
    code, out = run(copy)
    assert code == 1 and "not accounted for by any cross-reference entry" in out, out
    pdf.write_bytes(insert_before_xref(classic_pdf(), b"% a comment line\n\n"))  # comments and white space are fine
    assert run(copy)[0] == 0
    pdf.write_bytes(classic_pdf(lead=b"% hidden "))  # object 1's header sits inside an unterminated comment
    code, out = run(copy)
    assert code == 1 and "not accounted for by any cross-reference entry" in out, out
    pdf.write_bytes(classic_pdf(lead=b"% a whole comment line\r\n"))
    assert run(copy)[0] == 0


def test_superseded_stream_must_end_with_endobj(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(superseded_pdf(flate_stream(b"x")).replace(b"endstream\nendobj", b"endstream\nendobX", 1))
    code, out = run(copy)
    assert code == 1 and "not closed by endstream and endobj" in out, out


def test_decoded_byte_ceiling_applies_before_inflation(copy):
    import zlib
    pdf = next(copy.glob("*.pdf"))
    body = zlib.compress(b"\x01\x00\x09\x00")
    pdf.write_bytes(xref_stream_pdf(b"<< /Type /XRef /Size 1 /W [1 1000000000 1] /Root 1 0 R /Filter /FlateDecode /Length %d >>" % len(body), body))
    code, out = run(copy)
    assert code == 1 and "decoded bytes, above the ceiling" in out, out


def test_size_is_checked_at_every_section(copy):
    # the original section covers objects 0-3 but declares /Size 5; a later update adds object 4
    pdf = next(copy.glob("*.pdf"))
    raw = classic_pdf(edit=lambda b: b.replace(b"/Size 4 ", b"/Size 5 "))
    old_xref = int(re.search(rb"startxref\n(\d+)", raw).group(1))
    o4 = len(raw)
    raw += b"4 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 10 10] >>\nendobj\n"
    new_xref = len(raw)
    raw += b"xref\n4 1\n%010d 00000 n \ntrailer\n<< /Size 5 /Root 1 0 R /Prev %d >>\nstartxref\n%d\n%%%%EOF\n" % (o4, old_xref, new_xref)
    pdf.write_bytes(raw)
    code, out = run(copy)
    assert code == 1 and "/Size 5 is not one more than the highest object number 3" in out, out


def test_zero_count_subsection_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(classic_pdf(edit=lambda b: b.replace(b"trailer", b"9999 0\ntrailer").replace(b"/Size 4 ", b"/Size 9999 ")))
    code, out = run(copy)
    assert code == 1 and "empty xref subsection" in out, out


def test_type2_entry_to_non_object_stream_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    # object 1 declared as member 0 of "object stream" 2, which is the page tree, not an object stream
    pdf.write_bytes(xref_pdf(rows=lambda t, o1, o2, o3: [t[0], b"\x02\x00\x02\x00", *t[2:]]))
    code, out = run(copy)
    assert code == 1 and "not an object stream" in out, out


def test_predictor_parameters_are_validated(copy):
    pdf = next(copy.glob("*.pdf"))
    for params, message in ((b"/DecodeParms << /Columns 4 /Predictor 99 >> ", "unsupported /Predictor 99"),
                            (b"/DecodeParms << /Columns 999 /Predictor 12 >> ", "rows of 999 bytes but /W gives 4")):
        pdf.write_bytes(xref_pdf(predictor=True, dict_extra=params))
        code, out = run(copy)
        assert code == 1 and message in out, (params, out)


def test_xref_stream_must_list_itself(copy):
    pdf = next(copy.glob("*.pdf"))
    # the stream is object 99, /Size 5 and /Index [0 3 4 1] omit it, every listed row is valid
    pdf.write_bytes(xref_pdf(xref_num=99, rows=lambda t, *o: t[:3] + t[4:], dict_extra=b"/Index [0 3 4 1] "))
    code, out = run(copy)
    assert code == 1 and "object 99 0" in out and "not listed by its own section" in out, out
    # the stream is object 3 but its own row is free
    pdf.write_bytes(xref_pdf(rows=lambda t, *o: t[:3] + [b"\x00\x00\x00\x00"] + t[4:]))
    code, out = run(copy)
    assert code == 1 and "object 3 0" in out and "not listed by its own section" in out, out


def test_predictor_one_keeps_the_w_row_width(copy):
    pdf = next(copy.glob("*.pdf"))
    # five real four-byte rows followed by twenty arbitrary bytes under /Predictor 1 /Columns 8
    pdf.write_bytes(xref_pdf(rows=lambda t, *o: t + [b"\xff" * 4] * 5, dict_extra=b"/DecodeParms << /Predictor 1 /Columns 8 >> "))
    code, out = run(copy)
    assert code == 1 and "inflates past the declared row count" in out, out  # the /W width bounds the inflation first
    pdf.write_bytes(xref_pdf(dict_extra=b"/DecodeParms << /Predictor 1 /Columns 8 >> "))  # no surplus: geometry is irrelevant
    assert run(copy)[0] == 0


def test_zero_member_object_streams_carry_no_data(copy):
    pdf = next(copy.glob("*.pdf"))
    free5 = b"\x00\x00\x00\x00"
    pdf.write_bytes(objstm_pdf(members=[], body=b"hidden payload", row5=free5))  # /N 0 /First 0 over a nonempty body
    code, out = run(copy)
    assert code == 1 and "declares no members but carries data" in out, out
    pdf.write_bytes(objstm_pdf(members=[], body=b"\n", row5=free5))  # white space only
    assert run(copy)[0] == 0
    pdf.write_bytes(objstm_pdf(members=[], body=b"", row5=free5).replace(b"/N 0 /First 0", b"/N 0 /First 9"))  # /First beyond the data
    code, out = run(copy)
    assert code == 1 and "/First lies outside the data" in out, out


def test_object_stream_header_ends_at_a_token_boundary(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = objstm_pdf(body=b"true")  # data "5 0 true", /First 4
    assert raw.count(b"5 0 true") == 1 and raw.count(b"/First 4 ") == 1
    pdf.write_bytes(raw.replace(b"5 0 true", b"5 0true ", 1).replace(b"/First 4 ", b"/First 3 ", 1))  # "0true" is one token
    code, out = run(copy)
    assert code == 1 and "does not end at a token boundary at /First" in out, out
    pdf.write_bytes(raw.replace(b"5 0 true", b"5 0 (a) ", 1))  # a delimiter right at /First is a boundary
    assert run(copy)[0] == 0


def test_png_predictors_use_the_declared_pixel_width(copy):
    pdf = next(copy.glob("*.pdf"))
    pdf.write_bytes(objstm_pdf(png=(3, 3)))  # Sub filter over three-byte pixels, declared /Colors 3
    code, out = run(copy)
    assert code == 0, out
    pdf.write_bytes(objstm_pdf(png=(1, 3)))  # encoded byte-by-byte but declared /Colors 3: decodes to garbage
    code, out = run(copy)
    assert code == 1 and "object stream" in out, out
    pdf.write_bytes(xref_pdf(predictor=True, dict_extra=b"/DecodeParms << /Columns 2 /Colors 2 /Predictor 12 >> "))
    code, out = run(copy)
    assert code == 0, out


def test_missing_required_file_fails(copy):
    next(copy.glob("*.pdf")).unlink()
    code, out = run(copy)
    assert code == 1 and "required by the manifest but missing" in out


def test_empty_directory_fails(tmp_path):
    code, out = run(tmp_path)
    assert code == 1 and "missing manifest" in out


def test_inflated_classic_size_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    # /Size 99 keeps every subsection within bound, but the highest object number is 3
    pdf.write_bytes(classic_pdf(edit=lambda b: b.replace(b"/Size 4 ", b"/Size 99 ")))
    code, out = run(copy)
    assert code == 1 and "highest object number 3" in out, out


def test_inflated_xref_stream_size_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    # /Index keeps the row count consistent while /Size overstates the object-number extent
    pdf.write_bytes(xref_pdf(dict_extra=b"/Index [0 5] ").replace(b"/Size 5 ", b"/Size 99 "))
    code, out = run(copy)
    assert code == 1 and "highest object number 4" in out, out


def test_corrupted_ordinary_stream_fails(copy):
    pdf = next(copy.glob("*.pdf"))
    raw = bytearray(pdf.read_bytes())
    # the first content stream (a /Length-then-/Filter dictionary with no /Type); its offsets and
    # lengths are untouched, so only decoding the body can detect the flipped byte
    m = re.search(rb"\d+ 0 obj\n<<\n/Length \d+\s*\n/Filter /FlateDecode\n>>\nstream\n", bytes(raw))
    raw[m.end() + 40] ^= 0xFF
    pdf.write_bytes(bytes(raw))
    code, out = run(copy)
    assert code == 1 and "does not inflate" in out, out
