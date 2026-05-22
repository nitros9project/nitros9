# Annotation Patterns

Use this file when choosing names or comment style for 6809/6309 assembly.

## Label Patterns

- Subroutines: `InitVideo`, `ReadSector`, `PrintHexByte`
- Loops: `CopyLoop`, `WaitLoop`, `ScanKeyboardLoop`
- Conditional exits: `ReturnIfZero`, `ExitOnError`, `Done`
- Data tables: `Table_Sine`, `Table_Font8x8`, `Table_CommandPtrs`
- Pointers or buffers: `Ptr_Text`, `Ptr_Dest`, `Buffer_LineInput`
- Hardware-related targets: `WaitVBlank`, `AckInterrupt`, `UpdateDAC`

## Local Labels With `@`

If the source already uses local labels ending in `@`, keep that convention for short nearby control flow.

- Use `@` locals only while they remain in scope.
- Treat a blank line as the scope boundary.
- After a blank line, do not branch back to an earlier `@` local. Introduce a non-local label instead.

Example in scope:

```asm
CopyLoop@
        lda   ,x+          ; load next source byte
        sta   ,u+          ; store byte to destination
        decb               ; count one byte copied
        bne   CopyLoop@    ; continue until all bytes are copied
```

Example out of scope after a blank line:

```asm
CopyLoop@
        lda   ,x+          ; load next source byte
        sta   ,u+          ; store byte to destination
        decb               ; count one byte copied
        bne   CopyLoop@    ; continue until all bytes are copied

Done
        rts               ; return to caller
```

If later code needs to branch to `Done`, use `Done`, not `CopyLoop@`.

## Neutral Fallback Names

Use these only when intent is still unclear after reading nearby code:

- `Subroutine_C123`
- `BranchTarget_C140`
- `Table_C800`
- `DataBlock_D020`

## Comment Patterns

- State purpose: `; clear the current text row before redrawing`
- State condition: `; branch if checksum did not match`
- State role of memory: `; X points at the next command byte`
- State loop intent: `; copy B bytes from source to destination`
- State data meaning: `; 16-bit addresses for command handlers`

## Example

Before:

```asm
        LDX   #$C400
        LDB   #$20
L1      CLR   ,X+
        DECB
        BNE   L1
        RTS
```

After:

```asm
ClearBuffer
        LDX   #$C400       ; point X at the start of the buffer
        LDB   #$20         ; clear 32 bytes
ClearBufferLoop
        CLR   ,X+          ; zero the next byte and advance
        DECB               ; count one byte cleared
        BNE   ClearBufferLoop ; continue until all 32 bytes are zero
        RTS                ; return to caller
```
