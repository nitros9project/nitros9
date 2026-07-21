import contextlib
import io
import types
import unittest

import asmprettyprint


class AssemblyPrettyPrinterTests(unittest.TestCase):
    def format_line(self, source):
        args = types.SimpleNamespace(labelWidth=20, opcodeWidth=10, operandWidth=10)
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            asmprettyprint.processLine(args, source)
        return output.getvalue().rstrip('\n')

    def test_instruction_comment_gets_semicolon_and_lowercase_start(self):
        formatted = self.format_line('Loop  LDA  ,X+  Load next source byte\n')
        self.assertIn('; load next source byte', formatted)

    def test_existing_semicolon_is_not_duplicated(self):
        formatted = self.format_line('      BNE  Loop  ; Continue until complete\n')
        self.assertIn('; continue until complete', formatted)
        self.assertNotIn('; ;', formatted)

    def test_standalone_comment_keeps_asterisk(self):
        comment = '* Standalone OS-9 comment\n'
        self.assertEqual(self.format_line(comment), comment.rstrip())

    def test_data_rendering_is_not_rewritten_as_instruction_comment(self):
        formatted = self.format_line('Table FCB $41,$42 AB\n')
        self.assertTrue(formatted.endswith('AB'))
        self.assertNotIn('; AB', formatted)

    def test_uppercase_opcode_is_recognized(self):
        formatted = self.format_line('      RTS  Return to caller\n')
        self.assertIn('; return to caller', formatted)


if __name__ == '__main__':
    unittest.main()
