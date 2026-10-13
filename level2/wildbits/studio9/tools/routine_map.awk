# routine_map.awk - the routine index of one module, from its lwasm listing (make writes .mods/MAP/<module>.map).
# One line per routine label in the module's own sources (cmds/), in address order: module offset, name,
# file:line. Local labels (name@), equates, storage (rmb) and data (fcb/fcc/fcs/fcn/fdb/fill/includebin)
# are left out. The listing is regenerated on every assembly, so the index always matches the module.
BEGIN { data = " fcb fcc fcs fcn fdb fqb fill zmb rmb includebin use equ set org " }
/^[0-9A-F][0-9A-F][0-9A-F][0-9A-F] / {
    if (!match($0, /\( *cmds\/[^)]*\):[0-9]+/)) next
    loc = substr($0, RSTART, RLENGTH); gsub(/[( ]/, "", loc); sub(/\)/, "", loc)
    src = substr($0, RSTART + RLENGTH + 9)
    if (src !~ /^[A-Za-z_]/) next
    n = split(src, f, /[ \t]+/); label = f[1]; op = tolower(f[2])
    if (label ~ /@/) next
    if (op == "equ" && f[3] == "*") op = "code"
    if (index(data, " " op " ")) next
    printf "%s  %-28s %s\n", substr($0, 1, 4), label, loc
}
