# ssfm_startup.awk - used by immunity.mak when SSFM > 0.
# Adds "* and SuperSprite-FM+ board *" after the "on the ..." line of the
# startup file and pads the welcome lines so the closing asterisks line up.
{ line[NR] = $0 }
function pad(s, w,   t) {
    t = s
    while (length(t) < w - 1) t = t " "
    return t "*"
}
END {
    w = 0; on = 0
    for (i = 1; i <= NR; i++)
        if (line[i] ~ /^echo \* on the /) { on = i; w = length(line[i]) - 5 }
    for (i = 1; i <= NR; i++) {
        l = line[i]
        if (on && l ~ /^echo \* Welcome to NitrOS-9 Level 2 +\*$/)
            l = "echo " pad("* Welcome to NitrOS-9 Level 2", w)
        print l
        if (i == on)
            print "echo " pad("* and SuperSprite-FM+ board", w)
    }
}
