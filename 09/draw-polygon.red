Red [
    Needs: 'view
]

read-input: function [
    file [file!]
    return: [block!] ; block[point2D]
] [
    content: read/lines file
    collect [
        foreach ln content [
            parts: split ln #","
            keep as-point2D  to-integer parts/1  to-integer parts/2
        ]
    ]
]

min-pt: function [
    series [series!]
    return: [point2D!]
] [
    res: series/1
    foreach pt series [
        if pt/1 < res/1 [ res/1: pt/1 ]
        if pt/2 < res/2 [ res/2: pt/2 ]
    ]
    res
]

max-pt: function [
    series [series!]
    return: [point2D!]
] [
    res: series/1
    foreach pt series [
        if pt/1 > res/1 [ res/1: pt/1 ]
        if pt/2 > res/2 [ res/2: pt/2 ]
    ]
    res
]

crop: function [
    data [series!]
    return: [series!]
] [
    lo: min-pt data
    collect [
        foreach pt data [
            keep pt - (lo - 1)
        ]
    ]
]

scale: function [
    data [series!]
    factor [float!]
    return: [series!]
] [
    collect [
        foreach pt data [
            keep pt * factor
        ]
    ]
]

dim: function [
    data [series!]
    return: [pair!]
] [
    to-pair max-pt data
]

;data: read-input %example
data: read-input %input
data: crop data
data: scale data 0.1
size: dim data

img: make image! reduce [ dim data black ]

draw img compose [
    anti-alias off
    line-width 1
    pen (white)
    polygon (data)
]

save %img.png img
