
ordered_list_of_wall_indexes:
    .byte 18, 0, 1, 2, 3, 4, 5, 24, 6, 7, 8, 9, 10, 31, 11, 12, 30, 13, 28, 14, 29, 15, 16, 17, 19, 20, 21, 22, 23, 25, 26, 27

wall_info:
    .byte 32 ; number of walls
wall_0_info:
    .byte 5 , 13  ; start x, y
    .byte 5 , 12  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_1_info:
    .byte 5 , 12  ; start x, y
    .byte 5 , 11  ; end x, y
    .byte 7      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte CLD
wall_2_info:
    .byte 5 , 11  ; start x, y
    .byte 5 , 9  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS2
wall_3_info:
    .byte 5 , 8  ; start x, y
    .byte 5 , 7  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_4_info:
    .byte 5 , 7  ; start x, y
    .byte 5 , 6  ; end x, y
    .byte 7      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte CLD
wall_5_info:
    .byte 5 , 6  ; start x, y
    .byte 5 , 5  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_6_info:
    .byte 8 , 14  ; start x, y
    .byte 8 , 13  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_7_info:
    .byte 9 , 13  ; start x, y
    .byte 9 , 12  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_8_info:
    .byte 9 , 12  ; start x, y
    .byte 9 , 11  ; end x, y
    .byte 7      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte CLD
wall_9_info:
    .byte 9 , 11  ; start x, y
    .byte 9 , 7  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS2, BS1, BS1
wall_10_info:
    .byte 9 , 7  ; start x, y
    .byte 9 , 6  ; end x, y
    .byte 7      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte CLD
wall_11_info:
    .byte 9 , 6  ; start x, y
    .byte 9 , 4  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS2
wall_12_info:
    .byte 14 , 13  ; start x, y
    .byte 14 , 9  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS2, BS2, BS2, BS2
wall_13_info:
    .byte 14 , 8  ; start x, y
    .byte 14 , 5  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS2, BS1
wall_14_info:
    .byte 14 , 4  ; start x, y
    .byte 14 , 1  ; end x, y
    .byte 3      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS1, BS1
wall_15_info:
    .byte 1 , 1  ; start x, y
    .byte 1 , 4  ; end x, y
    .byte 1      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS2, BS1
wall_16_info:
    .byte 1 , 5  ; start x, y
    .byte 1 , 8  ; end x, y
    .byte 1      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS2, BS1
wall_17_info:
    .byte 1 , 9  ; start x, y
    .byte 1 , 13  ; end x, y
    .byte 1      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS2, BS1, BS1, BS2
wall_18_info:
    .byte 1 , 8  ; start x, y
    .byte 5 , 8  ; end x, y
    .byte 2      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS2, BS1, BS1
wall_19_info:
    .byte 10 , 8  ; start x, y
    .byte 14 , 8  ; end x, y
    .byte 2      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS1, BS1, BS1
wall_20_info:
    .byte 5 , 12  ; start x, y
    .byte 6 , 12  ; end x, y
    .byte 2      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_21_info:
    .byte 9 , 12  ; start x, y
    .byte 10 , 12  ; end x, y
    .byte 2      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_22_info:
    .byte 1 , 13  ; start x, y
    .byte 5 , 13  ; end x, y
    .byte 2      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS2, BS1, BS2
wall_23_info:
    .byte 6 , 13  ; start x, y
    .byte 7 , 13  ; end x, y
    .byte 2      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_24_info:
    .byte 7 , 13  ; start x, y
    .byte 8 , 13  ; end x, y
    .byte 6      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte CLD
wall_25_info:
    .byte 8 , 13  ; start x, y
    .byte 9 , 13  ; end x, y
    .byte 2      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_26_info:
    .byte 10 , 13  ; start x, y
    .byte 14 , 13  ; end x, y
    .byte 2      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS1, BS1, BS2
wall_27_info:
    .byte 14 , 1  ; start x, y
    .byte 1 , 1  ; end x, y
    .byte 0      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS1, BS2, BS1, BS2, BS1, BS1, BS2, BS1, BS1, BS1, BS2, BS1
wall_28_info:
    .byte 14 , 5  ; start x, y
    .byte 10 , 5  ; end x, y
    .byte 0      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS2, BS1, BS1
wall_29_info:
    .byte 5 , 5  ; start x, y
    .byte 1 , 5  ; end x, y
    .byte 0      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1, BS1, BS2, BS2
wall_30_info:
    .byte 10 , 6  ; start x, y
    .byte 9 , 6  ; end x, y
    .byte 0      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1
wall_31_info:
    .byte 6 , 6  ; start x, y
    .byte 5 , 6  ; end x, y
    .byte 0      ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)
    .byte BS1