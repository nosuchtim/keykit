# example code to post to keykit mailing list

function afractal(p) {
        p.pitch = p.pitch + rand(10)-5    # do your "fractal algorithm" here
        return(p)
    }

function amelody(n) {
    r = ''        # Start with an empty phrase.
    p = 'a'       # Set initial note, default duration is 1b, though you
    p.dur = 1b    # can set its duration explicitly.
    for ( i=0; i<n; i++ ) {
        p = afractal(p)     # generate new note
        r += p             # append it to the phrase we're constructing
    }
    return(r)
}
