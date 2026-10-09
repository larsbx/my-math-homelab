"""Issue #9 diagnostic. Run with --help for deterministic inputs and budgets."""

from std.sys import argv
from psc.bounded_bpa import build_bounded
from psc.bpa import sigma3
from psc.target_packets import build_packets, replay_path
from psc.target_packet_report import emit_report, emit_path, ints_json


def parse_sigma(text: String) raises -> List[List[Int]]:
    var sigma = List[List[Int]]()
    for image in text.split("/"):
        var word = List[Int]()
        for ch in image.codepoint_slices():
            var digit = String(ch)
            if digit != "0" and digit != "1" and digit != "2":
                raise Error("sigma images must contain only digits 0..2")
            word.append(atol(digit))
        if len(word) == 0:
            raise Error("sigma image must be nonempty")
        sigma.append(word^)
    _ = sigma3(sigma)
    return sigma^


def parse_positive(text: String) raises -> Int:
    if text.byte_length() == 0 or text.byte_length() > 8:
        raise Error("invalid diagnostic budget")
    for ch in text.codepoint_slices():
        var digit = String(ch)
        if digit < "0" or digit > "9":
            raise Error("diagnostic budget must be a positive integer")
    var n = atol(text)
    if n <= 0:
        raise Error("diagnostic budget must be positive")
    return n


def main() raises:
    var args = argv()
    var sigma: List[List[Int]] = [[1], [0, 2], [2, 0, 2]]
    var state_cap = 20000
    var length_cap = 10000
    var packet_cap = 200000
    var edge_cap = 2000000
    var target = -1
    var synchronize = False
    var dump = False
    var l1 = True
    var strict = False
    var weights: List[Int] = [1, 0, 0]
    var replay = List[Int]()
    var cycle = False
    var i = 1
    while i < len(args):
        var option = args[i]
        if option == "--help":
            print("target_aware_bpa.mojo [--sigma 1/02/202] [--target any|0|1|2|sync-right]")
            print("[--state-cap N] [--length-cap N] [--packet-cap N] [--edge-cap N]")
            print("[--dump] [--potential l1|linear] [--weights X Y Z] [--strict]")
            print("[--replay comma-separated-edge-IDs] [--cycle]")
            print("JSONL; zero-based letters; caps are inconclusive, never a theorem verdict.")
            return
        if option == "--dump":
            dump = True
        elif option == "--strict":
            strict = True
        elif option == "--cycle":
            cycle = True
        else:
            if i + 1 >= len(args):
                raise Error("missing value for diagnostic option")
            i += 1
            var value = args[i]
            if option == "--sigma":
                sigma = parse_sigma(value)
            elif option == "--state-cap":
                state_cap = parse_positive(value)
            elif option == "--length-cap":
                length_cap = parse_positive(value)
            elif option == "--packet-cap":
                packet_cap = parse_positive(value)
            elif option == "--edge-cap":
                edge_cap = parse_positive(value)
            elif option == "--target":
                synchronize = value == "sync-right"
                if value == "any" or synchronize:
                    target = -1
                elif value == "0" or value == "1" or value == "2":
                    target = atol(value)
                else:
                    raise Error("target must be any, 0, 1, 2, or sync-right")
            elif option == "--potential":
                if value != "l1" and value != "linear":
                    raise Error("potential must be l1 or linear")
                l1 = value == "l1"
            elif option == "--weights":
                if i + 2 >= len(args):
                    raise Error("weights need three signed integers")
                for k in range(3):
                    var text = args[i + k]
                    var unsigned = String(text)
                    if text.startswith("-"):
                        unsigned = String(text[byte=1:])
                    # parse_positive also rejects non-digits; zero is permitted here.
                    if unsigned == "0":
                        weights[k] = 0
                    else:
                        _ = parse_positive(unsigned)
                        weights[k] = atol(text)
                i += 2
            elif option == "--replay":
                for digit in value.split(","):
                    var text = String(digit)
                    replay.append(0 if text == "0" else parse_positive(text))
            else:
                raise Error("unknown target-packet diagnostic option")
        i += 1
    print(String('{"record":"budget","bpa_states":') + String(state_cap) + ',"bpa_length":' + String(length_cap)
          + ',"packets":' + String(packet_cap) + ',"edges":' + String(edge_cap) + '}')
    var bounded = build_bounded(sigma3(sigma), state_cap, length_cap)
    if not bounded.complete():
        print(String('{"record":"inconclusive","budget_kind":') + String(bounded.exhausted) + '}')
        raise Error("BPA budget exhausted; no diagnostic verdict")
    var g = build_packets(sigma, bounded.graph, packet_cap, edge_cap, target, synchronize)
    emit_report(g, dump, weights, l1, strict)
    if cycle and len(replay) == 0:
        raise Error("--cycle needs a --replay path")
    if len(replay) > 0:
        if not replay_path(g, replay, cycle):
            raise Error("requested packet witness did not replay")
        print(String('{"record":"requested_replay","edges":') + ints_json(replay) + ',"replayed":true}')
        emit_path(g, replay)
