import unittest

from support import load

T = load("paper/associator-defects/make_tables.py", "paper_tables")
GUARDS_CONTRACT = "paper/associator-defects tables are generated from the committed census and mutant data"


class TestPaperTables(unittest.TestCase):
    def test_tables_are_current(self):
        for name, render in T.TABLES.items():
            with self.subTest(table=name):
                self.assertEqual((T.HERE / "tables" / name).read_text(encoding="utf-8"), render())

    def test_every_mutant_was_killed(self):
        import json
        mutants = json.loads(T.MUTANTS.read_text(encoding="utf-8"))["mutants"]
        self.assertTrue(mutants and all(m["killed"] for m in mutants))
        self.assertEqual({m["mutant"] for m in mutants}, set(T.MUTANT_TEX))


if __name__ == "__main__":
    unittest.main()
