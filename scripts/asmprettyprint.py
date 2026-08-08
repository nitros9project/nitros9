import argparse
import re
import sys

# parameters
stripWhitesSpaceAtEnd = True

opcodesWithoutOperands = [
    'abx',
    'asla', 'aslb', 'asld', 'aslq',
    'asra', 'asrb', 'asrd', 'asrq',
    'break',
    'clra', 'clrb', 'clrd', 'comd', 'clre', 'clrf', 'clrw', 'clrq',
    'coma', 'comb', 'comd', 'come', 'comf', 'comw', 'comq',
    'daa',
    'deca', 'decb', 'dece', 'decf', 'decw', 'sync',
    'inca', 'incb', 'incd', 'ince', 'incf', 'incw',
    'log',
    'lsla', 'lslb', 'lsld', 'lsle', 'lslf', 'lslq',
    'lsra', 'lsrb', 'lsrd', 'lsre', 'lsrf', 'lsrq',
    'mul',
    'nega', 'negb', 'negd', 'nege', 'negf', 'negw', 'negq',
    'rti', 'rts',
    'rola', 'rolb', 'rold', 'rolw',
    'rora', 'rorb', 'rord', 'rorw',
    'sex', 'sexw', 'swi', 'swi2', 'swi3',
    'tsta', 'tstb', 'tstd', 'tste', 'tstf', 'tstw', 'tstq',
    # psedu-ops
    'ifp1', 'else', 'endc'
]

pseudoOpcodes = ['ifp1', 'ifgt', 'iflt', 'ifge', 'ifle', 'ifeq', 'ifne',
    'else', 'endc'
]

opcodesWithOperandsThatCanHaveSpaces = [
    'ttl', 'fcc', 'fcs'
]

# Pseudo-ops and data directives are not executable instructions.  Their
# trailing text may be an ASCII rendering or directive-specific payload, so
# only true instruction comments receive the canonical ``; lowercase`` form.
nonExecutableOpcodes = {
    'align', 'bsz', 'end', 'endc', 'endm', 'endr', 'ends', 'endsection',
    'else', 'emod', 'equ', 'export', 'external', 'fcb', 'fcc', 'fcs', 'fdb',
    'fill', 'if', 'ifeq', 'ifge', 'ifgt', 'ifle', 'iflt', 'ifne', 'ifp1',
    'ifp2', 'include', 'macro', 'mod', 'nam', 'org', 'pag', 'rept', 'rmb',
    'section', 'set', 'struct', 'ttl', 'use', 'zmb'
}

def normalizeInstructionComment(opcode, comment):
    """Return a canonical inline comment for an executable instruction."""
    if opcode == "" or comment == "" or opcode.lower() in nonExecutableOpcodes:
        return comment

    normalized = comment.strip()
    if normalized.startswith(';'):
        normalized = normalized[1:].lstrip()

    # Lowercase the initial word while leaving later proper nouns and symbols
    # untouched.  This handles both ordinary prose (Load -> load) and leading
    # acronyms (SS.Opt -> ss.Opt).
    match = re.match(r'^([A-Z]+)', normalized)
    if match:
        normalized = match.group(1).lower() + normalized[match.end():]

    return '; ' + normalized

def isEmptyLine(l):
    l.strip()
    if len(l) == 0:
        return True
    else:
        return False

def isComment(l):
    if l[0] == '*' or l[0] == ';':
        return True
    else:
        return False

def hasLabel(l):
    result = False
    if len(l) > 0 and not l[0].isspace():
        result = True
    return result

def showLine(label, opcode, operand, comment, labelWidth, opcodeWidth, operandWidth, debug):
    if debug == True:
        line = [label, opcode, operand, comment]
    else:
        if label == "" and opcode == "" and operand == "":
            line = comment
        else:
            formatString = f"{label:<{labelWidth}} {opcode:<{opcodeWidth}} {operand:<{operandWidth}} {comment:<{0}}"
            line = formatString
    if stripWhitesSpaceAtEnd == True:
        line = line.rstrip()
    print(line)

def processLine(args, l):
    line = ""
    label = ""
    opcode = ""
    operand = ""
    comment = ""
    labelWidth = args.labelWidth - 1
    opcodeWidth = args.opcodeWidth - 1
    operandWidth = args.operandWidth - 1
    
    l = l.rstrip('\n')
    if isEmptyLine(l) == True:
        comment = ""
    elif isComment(l) == True:
        comment = l
    else:
        tokens = l.split()
        startIndex = 0
        if hasLabel(l) == True:
            # the next token will be a label
            label = tokens[startIndex]
            startIndex = startIndex + 1
        # the first token will be the opcode
        if len(tokens) > startIndex:
            opcode = tokens[startIndex]
            # if the opcode is in the pseudo-op table, indent it less and make it uppercase
            if opcode.lower() in pseudoOpcodes:
                opcode = opcode.upper()
                labelWidth -= 2
                opcodeWidth -=2
                operandWidth -= 2
            # if there's a second token AND the first token takes an operand, the second token is an operand
            if len(tokens) > startIndex + 1 and opcode.lower() not in opcodesWithoutOperands:
                operand = tokens[startIndex + 1]
                if len(tokens) > startIndex + 2:
                    if opcode.lower() in opcodesWithOperandsThatCanHaveSpaces:
                        operand = l.split(None, startIndex + 1)[startIndex + 1]
                    else:
                        comment = l.split(None, startIndex + 2)[startIndex + 2]
                else:
                    comment = ""
            else:
                if len(tokens) > startIndex + 1:
                    comment = l.split(None, startIndex + 1)[startIndex + 1]

    comment = normalizeInstructionComment(opcode, comment)
    showLine(label, opcode, operand, comment, labelWidth, opcodeWidth, operandWidth, False)

def main():
    parser = argparse.ArgumentParser(description='Command line parser.')

    parser.add_argument('filename')           # positional argument

    parser.add_argument("--labelWidth", type=int, help="Label width", default=20)

    parser.add_argument("--opcodeWidth", type=int, help="Opcode width", default=10)

    parser.add_argument("--operandWidth", type=int, help="Operand width", default=10)

    args = parser.parse_args()

    # Using the 'with' statement ensures that the file is properly closed after its suite finishes.
    with open(args.filename, 'r') as file:
        for line in file:
            processLine(args, line)


if __name__ == '__main__':
    main()
