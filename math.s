

; See: https://github.com/commanderx16/x16-demo/blob/master/cc65-sprite/demo.c

; Python script to generate the table:
; import math
; # cycle=320
; cycle=1824
; ampl=256
; [int(math.sin(float(i)/cycle*2.0*math.pi)*ampl+0.5) for i in range(cycle)]
; [int(math.cos(float(i)/cycle*2.0*math.pi)*ampl+0.5) for i in range(cycle)]

; [int(math.tan(float(i)/cycle*2.0*math.pi)*ampl+0.5) for i in range(cycle)]

; The math.atan() method returns the arc tangent of a number (x) as a numeric value between -PI/2 and PI/2 radians.
; example: math.atan(55/256)/(math.pi*2.0)*1824
; FIXME: shouldnt there be a +0.5 here somewhere?
; [int(math.atan(j/ampl)/(math.pi*2.0)*cycle) for j in range(ampl)]

; log2: (to be used for atan calculation: (does NOT contain 0!)
; [math.floor(256*math.log2(((i)/16)))/256 for i in range(1, 16*256)]

; Testing:


; Let y = 0.5 (0.128) and x = 1.0 (1.0)
; What we want to see: 1824/2*math.atan(0.5/1.0)/math.pi = 134.59625929719513
; log2(y) = math.floor(256*math.log2(((128)/256)))/256 = -1 = -1*256
; log2(x) = math.floor(256*math.log2(((256)/256)))/256 = 0.0 = 0*256
; log2(y) - log2(x) = -1 - 0 = -1

; table index -1 contains: 1824/2*math.atan(2**((-1*256)/256))/math.pi = 134.59625929719513 --> OK

; Let y = 0.4 (0*256+102) and x = 1.3 (1*256+77)
; What we want to see: 1824/2*math.atan(0.4/1.3)/math.pi = 86.65382677653201
; log2(y) = math.floor(256*math.log2(((0*256+102)/256)))/256 = -1.328125 = -1*256-84
; log2(x) = math.floor(256*math.log2(((1*256+77)/256)))/256 = 0.37890625 = 0*256+97
; log2(y) - log2(x) = (-1*256-84) - (0*256+97) = -437 = -(1*256+181)

; table index -(1*256+181) contains: 1824/2*math.atan(2**(-(1*256+181)/256))/math.pi = 86.28171992564408 --> OK


; Let y = 12.4 (12*256+102) and x = 1.3 (1*256+77)
; What we want to see: 1824/2*math.atan(12.4/1.3)/math.pi = 425.6762416034153
; log2(y) = math.floor(256*math.log2(((12*256+102)/256)))/256 = 3.62890625 = 3*256+161
; log2(x) = math.floor(256*math.log2(((1*256+77)/256)))/256 = 0.37890625 = 0*256+97
; log2(y) - log2(x) = (3*256+161) - (0*256+97) = 832 = 3*256+64

; table index 3*256+64 contains: 1824/2*math.atan(2**((3*256+64)/256))/math.pi = 425.5977556350432 --> OK


; Also see: https://csdb.dk/forums/?roomid=11&topicid=26608&firstpost=2


; FIXME: we only need ONE byte per entry for sine and cosine! (the last few are 256, but that can be handled a different way)

; This is a list of 8.8 bit values (so 16 bits each, 8 bits for fraction, 8 bits for whole number)
; Since there are 456 angle-indexes per 90 degrees, this list contains 456 values (actually a bit more, but I am lazy and havent removed the last/extra ones).
sine:
    .word 0, 1, 2, 3, 4, 4, 5, 6, 7, 8, 9, 10, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 23, 24, 25, 26, 26, 27, 28, 29, 30, 31, 32, 33, 33, 34, 35, 36, 37, 38, 39, 40, 40, 41, 42, 43, 44, 45, 46, 46, 47, 48, 49, 50, 51, 52, 53, 53, 54, 55, 56, 57, 58, 59, 59, 60, 61, 62, 63, 64, 65, 65, 66, 67, 68, 69, 70, 71, 71, 72, 73, 74, 75, 76, 76, 77, 78, 79, 80, 81, 81, 82, 83, 84, 85, 86, 86, 87, 88, 89, 90, 91, 91, 92, 93, 94, 95, 96, 96, 97, 98, 99, 100, 100, 101, 102, 103, 104, 104, 105, 106, 107, 108, 108, 109, 110, 111, 112, 112, 113, 114, 115, 116, 116, 117, 118, 119, 120, 120, 121, 122, 123, 123, 124, 125, 126, 126, 127, 128, 129, 130, 130, 131, 132, 133, 133, 134, 135, 136, 136, 137, 138, 139, 139, 140, 141, 141, 142, 143, 144, 144, 145, 146, 147, 147, 148, 149, 149, 150, 151, 152, 152, 153, 154, 154, 155, 156, 157, 157, 158, 159, 159, 160, 161, 161, 162, 163, 163, 164, 165, 165, 166, 167, 167, 168, 169, 169, 170, 171, 171, 172, 173, 173, 174, 175, 175, 176, 177, 177, 178, 179, 179, 180, 180, 181, 182, 182, 183, 183, 184, 185, 185, 186, 187, 187, 188, 188, 189, 190, 190, 191, 191, 192, 192, 193, 194, 194, 195, 195, 196, 196, 197, 198, 198, 199, 199, 200, 200, 201, 201, 202, 203, 203, 204, 204, 205, 205, 206, 206, 207, 207, 208, 208, 209, 209, 210, 210, 211, 211, 212, 212, 213, 213, 214, 214, 215, 215, 216, 216, 217, 217, 218, 218, 219, 219, 219, 220, 220, 221, 221, 222, 222, 223, 223, 223, 224, 224, 225, 225, 226, 226, 226, 227, 227, 228, 228, 228, 229, 229, 230, 230, 230, 231, 231, 232, 232, 232, 233, 233, 233, 234, 234, 234, 235, 235, 235, 236, 236, 237, 237, 237, 238, 238, 238, 238, 239, 239, 239, 240, 240, 240, 241, 241, 241, 242, 242, 242, 242, 243, 243, 243, 244, 244, 244, 244, 245, 245, 245, 245, 246, 246, 246, 246, 247, 247, 247, 247, 248, 248, 248, 248, 248, 249, 249, 249, 249, 249, 250, 250, 250, 250, 250, 251, 251, 251, 251, 251, 251, 252, 252, 252, 252, 252, 252, 253, 253, 253, 253, 253, 253, 253, 253, 254, 254, 254, 254, 254, 254, 254, 254, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 255

; This is a list of 8 bit values (8 bits for a fraction, no bits for the whole number, since that is assumed to be 0)
; Since there are 456 angle-indexes per 90 degrees, this list contains 456 values (actually a bit more, but I am lazy and havent removed the last/extra ones).
cosine:
    .word 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 254, 254, 254, 254, 254, 254, 254, 254, 253, 253, 253, 253, 253, 253, 253, 253, 252, 252, 252, 252, 252, 252, 251, 251, 251, 251, 251, 251, 250, 250, 250, 250, 250, 249, 249, 249, 249, 249, 248, 248, 248, 248, 248, 247, 247, 247, 247, 246, 246, 246, 246, 245, 245, 245, 245, 244, 244, 244, 244, 243, 243, 243, 242, 242, 242, 242, 241, 241, 241, 240, 240, 240, 239, 239, 239, 238, 238, 238, 238, 237, 237, 237, 236, 236, 235, 235, 235, 234, 234, 234, 233, 233, 233, 232, 232, 232, 231, 231, 230, 230, 230, 229, 229, 228, 228, 228, 227, 227, 226, 226, 226, 225, 225, 224, 224, 223, 223, 223, 222, 222, 221, 221, 220, 220, 219, 219, 219, 218, 218, 217, 217, 216, 216, 215, 215, 214, 214, 213, 213, 212, 212, 211, 211, 210, 210, 209, 209, 208, 208, 207, 207, 206, 206, 205, 205, 204, 204, 203, 203, 202, 201, 201, 200, 200, 199, 199, 198, 198, 197, 196, 196, 195, 195, 194, 194, 193, 192, 192, 191, 191, 190, 190, 189, 188, 188, 187, 187, 186, 185, 185, 184, 183, 183, 182, 182, 181, 180, 180, 179, 179, 178, 177, 177, 176, 175, 175, 174, 173, 173, 172, 171, 171, 170, 169, 169, 168, 167, 167, 166, 165, 165, 164, 163, 163, 162, 161, 161, 160, 159, 159, 158, 157, 157, 156, 155, 154, 154, 153, 152, 152, 151, 150, 149, 149, 148, 147, 147, 146, 145, 144, 144, 143, 142, 141, 141, 140, 139, 139, 138, 137, 136, 136, 135, 134, 133, 133, 132, 131, 130, 130, 129, 128, 127, 126, 126, 125, 124, 123, 123, 122, 121, 120, 120, 119, 118, 117, 116, 116, 115, 114, 113, 112, 112, 111, 110, 109, 108, 108, 107, 106, 105, 104, 104, 103, 102, 101, 100, 100, 99, 98, 97, 96, 96, 95, 94, 93, 92, 91, 91, 90, 89, 88, 87, 86, 86, 85, 84, 83, 82, 81, 81, 80, 79, 78, 77, 76, 76, 75, 74, 73, 72, 71, 71, 70, 69, 68, 67, 66, 65, 65, 64, 63, 62, 61, 60, 59, 59, 58, 57, 56, 55, 54, 53, 53, 52, 51, 50, 49, 48, 47, 46, 46, 45, 44, 43, 42, 41, 40, 40, 39, 38, 37, 36, 35, 34, 33, 33, 32, 31, 30, 29, 28, 27, 26, 26, 25, 24, 23, 22, 21, 20, 19, 19, 18, 17, 16, 15, 14, 13, 12, 11, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 1, 0, 0

; This is a list of 8.8 bit values (so 16 bits each, 8 bits for fraction, 8 bits for whole number)
; Since there are 456 angle-indexes per 90 degrees, this list contains 456 values.
tangent:
    ; FIXME: DOUBLE CHECK THIS, ESPECIALLY THE NUMBERS AT THE END!
    ; FIXME: store these as two list of high byte and low byte instead from the beginning! (aligned to a page)
    .word 0, 1, 2, 3, 4, 4, 5, 6, 7, 8,  9, 10, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 23, 24, 25, 26, 27, 27, 28, 29, 30, 31, 32, 33, 34, 35, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 130, 131, 132, 133, 134, 135, 136, 137, 139, 140, 141, 142, 143, 144, 145, 147, 148, 149, 150, 151, 153, 154, 155, 156, 157, 159, 160, 161, 162, 164, 165, 166, 167, 169, 170, 171, 172, 174, 175, 176, 178, 179, 180, 181, 183, 184, 185, 187, 188, 190, 191, 192, 194, 195, 196, 198, 199, 201, 202, 204, 205, 206, 208, 209, 211, 212, 214, 215, 217, 218, 220, 221, 223, 225, 226, 228, 229, 231, 232, 234, 236, 237, 239, 241, 242, 244, 246, 247, 249, 251, 252, 254, 256, 258, 260, 261, 263, 265, 267, 269, 271, 272, 274, 276, 278, 280, 282, 284, 286, 288, 290, 292, 294, 296, 298, 300, 302, 304, 307, 309, 311, 313, 315, 317, 320, 322, 324, 327, 329, 331, 334, 336, 338, 341, 343, 346, 348, 351, 353, 356, 359, 361, 364, 367, 369, 372, 375, 377, 380, 383, 386, 389, 392, 395, 398, 401, 404, 407, 410, 413, 416, 420, 423, 426, 430, 433, 436, 440, 443, 447, 451, 454, 458, 462, 465, 469, 473, 477, 481, 485, 489, 493, 497, 502, 506, 510, 515, 519, 524, 528, 533, 538, 542, 547, 552, 557, 562, 568, 573, 578, 584, 589, 595, 600, 606, 612, 618, 624, 630, 637, 643, 649, 656, 663, 670, 677, 684, 691, 698, 706, 714, 721, 729, 737, 746, 754, 763, 772, 781, 790, 799, 809, 818, 828, 839, 849, 860, 871, 882, 894, 905, 917, 930, 942, 955, 969, 982, 996, 1011, 1026, 1041, 1057, 1073, 1089, 1107, 1124, 1142, 1161, 1180, 1200, 1221, 1242, 1264, 1287, 1311, 1335, 1360, 1387, 1414, 1442, 1472, 1502, 1534, 1567, 1602, 1638, 1676, 1716, 1757, 1801, 1846, 1894, 1945, 1998, 2054, 2113, 2176, 2242, 2313, 2388, 2468, 2554, 2646, 2745, 2851, 2965, 3089, 3224, 3372, 3533, 3710, 3906, 4123, 4367, 4640, 4950, 5304, 5713, 6190, 6753, 7429, 8255, 9287, 10615, 12384, 14862, 18578, 24771, 32767/2, 32767/2, 32767/2
    ; idx 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228

; This is a list of number between 0 and 228 representing an angle. There are 256 entries which indicate the result after a y/x division: 8-bit number (0.8 bits). So this covers 45 degrees.
; Also see: https://www.microchip.com/forums/m817546.aspx
invtangent:
    ; manually: .byte 0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 38, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 64, 65, 
    .byte 0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32, 33, 34, 36, 37, 38, 39, 40, 41, 42, 43, 44, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 139, 140, 141, 142, 143, 144, 145, 146, 147, 147, 148, 149, 150, 151, 152, 153, 153, 154, 155, 156, 157, 158, 158, 159, 160, 161, 162, 162, 163, 164, 165, 166, 167, 167, 168, 169, 170, 170, 171, 172, 173, 174, 174, 175, 176, 177, 177, 178, 179, 180, 180, 181, 182, 183, 183, 184, 185, 186, 186, 187, 188, 188, 189, 190, 191, 191, 192, 193, 193, 194, 195, 196, 196, 197, 198, 198, 199, 200, 200, 201, 202, 202, 203, 204, 204, 205, 206, 206, 207, 208, 208, 209, 209, 210, 211, 211, 212, 213, 213, 214, 214, 215, 216, 216, 217, 218, 218, 219, 219, 220, 221, 221, 222, 222, 223, 223, 224, 225, 225, 226, 226, 227
    ; idx 0, 1, 2, 3, 4, 5, 6, 7, 8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255
    
init_sine:

    lda #<sine
    sta LOAD_ADDRESS
    lda #>sine
    sta LOAD_ADDRESS+1
    
    ldx #0
next_sine_value_first_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta SINE_LOW, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta SINE_HIGH, x
    
    inx
    beq done_sine_first_part
    
    inc LOAD_ADDRESS
    bne sine_incemented_load_address_once_first
    inc LOAD_ADDRESS+1
sine_incemented_load_address_once_first:
    inc LOAD_ADDRESS
    bne sine_incemented_load_address_twice_first
    inc LOAD_ADDRESS+1
sine_incemented_load_address_twice_first:
    bra next_sine_value_first_part
    
done_sine_first_part:
    
    lda #<(sine+512)
    sta LOAD_ADDRESS
    lda #>(sine+512)
    sta LOAD_ADDRESS+1
    
    ldx #0
next_sine_value_last_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta SINE_LOW+256, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta SINE_HIGH+256, x
    
    inx
    cpx #(456-256)
    beq done_sine_last_part
    
    inc LOAD_ADDRESS
    bne sine_incemented_load_address_once_last
    inc LOAD_ADDRESS+1
sine_incemented_load_address_once_last:
    inc LOAD_ADDRESS
    bne sine_incemented_load_address_twice_last
    inc LOAD_ADDRESS+1
sine_incemented_load_address_twice_last:
    bra next_sine_value_last_part
    
done_sine_last_part:

    rts

init_cosine:

    lda #<cosine
    sta LOAD_ADDRESS
    lda #>cosine
    sta LOAD_ADDRESS+1
    
    ldx #0
next_cosine_value_first_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta COSINE_LOW, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta COSINE_HIGH, x
    
    inx
    beq done_cosine_first_part
    
    inc LOAD_ADDRESS
    bne cosine_incemented_load_address_once_first
    inc LOAD_ADDRESS+1
cosine_incemented_load_address_once_first:
    inc LOAD_ADDRESS
    bne cosine_incemented_load_address_twice_first
    inc LOAD_ADDRESS+1
cosine_incemented_load_address_twice_first:
    bra next_cosine_value_first_part
    
done_cosine_first_part:
    
    lda #<(cosine+512)
    sta LOAD_ADDRESS
    lda #>(cosine+512)
    sta LOAD_ADDRESS+1
    
    ldx #0
next_cosine_value_last_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta COSINE_LOW+256, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta COSINE_HIGH+256, x
    
    inx
    cpx #(456-256)
    beq done_cosine_last_part
    
    inc LOAD_ADDRESS
    bne cosine_incemented_load_address_once_last
    inc LOAD_ADDRESS+1
cosine_incemented_load_address_once_last:
    inc LOAD_ADDRESS
    bne cosine_incemented_load_address_twice_last
    inc LOAD_ADDRESS+1
cosine_incemented_load_address_twice_last:
    bra next_cosine_value_last_part
    
done_cosine_last_part:

    rts
    
    
init_tangent:

    lda #<tangent
    sta LOAD_ADDRESS
    lda #>tangent
    sta LOAD_ADDRESS+1
    
    ldx #0
next_tangent_value_first_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta TANGENT_LOW, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta TANGENT_HIGH, x
    
    inx
    beq done_tangent_first_part
    
    inc LOAD_ADDRESS
    bne tangent_incemented_load_address_once_first
    inc LOAD_ADDRESS+1
tangent_incemented_load_address_once_first:
    inc LOAD_ADDRESS
    bne tangent_incemented_load_address_twice_first
    inc LOAD_ADDRESS+1
tangent_incemented_load_address_twice_first:
    bra next_tangent_value_first_part
    
done_tangent_first_part:
    
    lda #<(tangent+512)
    sta LOAD_ADDRESS
    lda #>(tangent+512)
    sta LOAD_ADDRESS+1
    
    ldx #0
next_tangent_value_last_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta TANGENT_LOW+256, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta TANGENT_HIGH+256, x
    
    inx
    cpx #(456-256)
    beq done_tangent_last_part
    
    inc LOAD_ADDRESS
    bne tangent_incemented_load_address_once_last
    inc LOAD_ADDRESS+1
tangent_incemented_load_address_once_last:
    inc LOAD_ADDRESS
    bne tangent_incemented_load_address_twice_last
    inc LOAD_ADDRESS+1
tangent_incemented_load_address_twice_last:
    bra next_tangent_value_last_part
    
done_tangent_last_part:

    rts




; https://codebase64.org/doku.php?id=base:16bit_division_16-bit_result

divide_16bits:
    phx
    phy

    lda #0            ; preset REMAINDER to 0
    sta REMAINDER
    sta REMAINDER+1
    ldx #16            ; repeat for each bit: ...

div16loop:
    asl DIVIDEND    ; DIVIDEND lb & hb*2, msb -> Carry
    rol DIVIDEND+1    
    rol REMAINDER    ; REMAINDER lb & hb * 2 + msb from carry
    rol REMAINDER+1
    lda REMAINDER
    sec
    sbc DIVISOR        ; substract DIVISOR to see if it fits in
    tay                ; lb result -> Y, for we may need it later
    lda REMAINDER+1
    sbc DIVISOR+1
    bcc div16skip     ; if carry=0 then DIVISOR didnt fit in yet

    sta REMAINDER+1
    sty REMAINDER    
    inc DIVIDEND    ; and INCrement result cause DIVISOR fit in 1 times

div16skip:
    dex
    bne div16loop    
    
    ply
    plx
    rts

    
; https://codebase64.org/doku.php?id=base:24bit_division_24-bit_result

divide_24bits:
    phx
    phy

    lda #0            ; preset REMAINDER to 0
    sta REMAINDER
    sta REMAINDER+1
    sta REMAINDER+2
    ldx #24            ; repeat for each bit: ...

div24loop:
    asl DIVIDEND    ; DIVIDEND lb & hb*2, msb -> Carry
    rol DIVIDEND+1    
    rol DIVIDEND+2
    rol REMAINDER    ; REMAINDER lb & hb * 2 + msb from carry
    rol REMAINDER+1
    rol REMAINDER+2
    lda REMAINDER
    sec
    sbc DIVISOR        ; substract DIVISOR to see if it fits in
    tay                ; lb result -> Y, for we may need it later
    lda REMAINDER+1
    sbc DIVISOR+1
    sta TMP1
    lda REMAINDER+2
    sbc DIVISOR+2
    bcc div24skip     ; if carry=0 then DIVISOR didnt fit in yet

    sta REMAINDER+2 ; else save substraction result as new REMAINDER,
    lda TMP1
    sta REMAINDER+1
    sty REMAINDER    
    inc DIVIDEND    ; and INCrement result cause DIVISOR fit in 1 times

div24skip:
    dex
    bne div24loop    
    
    ply
    plx
    rts


    
; https://codebase64.org/doku.php?id=base:16bit_multiplication_32-bit_product

multply_16bits:
    phx
    lda    #$00
    sta    PRODUCT+2    ; clear upper bits of PRODUCT
    sta    PRODUCT+3 
    ldx    #$10         ; set binary count to 16 
shift_r:
    lsr    MULTIPLIER+1 ; divide MULTIPLIER by 2 
    ror    MULTIPLIER
    bcc    rotate_r 
    lda    PRODUCT+2    ; get upper half of PRODUCT and add MULTIPLICAND
    clc
    adc    MULTIPLICAND
    sta    PRODUCT+2
    lda    PRODUCT+3 
    adc    MULTIPLICAND+1
rotate_r:
    ror                 ; rotate partial PRODUCT 
    sta    PRODUCT+3 
    ror    PRODUCT+2
    ror    PRODUCT+1 
    ror    PRODUCT 
    dex
    bne    shift_r 
    plx
    
    rts


; Here we create square-tables for fast multiplication
    
; This is from here: https://codebase64.org/doku.php?id=base:seriously_fast_multiplication
; More explation can be found here: https://llx.com/Neil/a2/mult.html
    
generate_multiplication_tables:
gmt:

      ; Create first square table (I*I)/4
      ldx #$00
      txa
      .byte $c9   ; CMP #immediate - skip TYA and clear carry flag
lb1:  tya
      adc #$00
ml1:  sta SQUARE1_HIGH,x
      tay
      cmp #$40
      txa
      ror
ml9:  adc #$00
      sta ml9+1-gmt+GENERATE_MULT_TABLES
      inx
ml0:  sta SQUARE1_LOW,x
      bne lb1
      inc ml0+2-gmt+GENERATE_MULT_TABLES
      inc ml1+2-gmt+GENERATE_MULT_TABLES
      clc
      iny
      bne lb1

      ; Create second square table ((I-255)*(I-255))/4
      ldx #$00
      ldy #$FF
next_square_entry:
      lda SQUARE1_HIGH+1,x
      sta SQUARE2_HIGH+$100,x
      lda SQUARE1_HIGH,x
      sta SQUARE2_HIGH,y
      lda SQUARE1_LOW+1,x
      sta SQUARE2_LOW+$100,x
      lda SQUARE1_LOW,x
      sta SQUARE2_LOW,y
      dey
      inx
      bne next_square_entry
      
      rts
end_of_generate_multiplication_tables:
      

setup_multiply_with_normal_distance_16bit:

    lda NORMAL_DISTANCE_TO_WALL+0         
    sta mnd_sm1a+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm3a+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm5a+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm7a+1-mnd+MULT_WITH_NORMAL_DISTANCE
    eor #$ff         
    sta mnd_sm2a+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm4a+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm6a+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm8a+1-mnd+MULT_WITH_NORMAL_DISTANCE
    lda NORMAL_DISTANCE_TO_WALL+1         
    sta mnd_sm1b+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm3b+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm5b+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm7b+1-mnd+MULT_WITH_NORMAL_DISTANCE
    eor #$ff         
    sta mnd_sm2b+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm4b+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm6b+1-mnd+MULT_WITH_NORMAL_DISTANCE
    sta mnd_sm8b+1-mnd+MULT_WITH_NORMAL_DISTANCE
    
    rts
  
multply_with_normal_distance_16bits:
mnd:
; SPEED: can we avoid putting x on the stack?
    phx
    
      ; Perform <T1 * <MULTIPLICAND = AAaa
      ldx MULTIPLICAND+0
      sec
mnd_sm1a: lda SQUARE1_LOW,x
mnd_sm2a: sbc SQUARE2_LOW,x
; SPEED: do we need PRODUCT+0?
      sta PRODUCT+0             
mnd_sm3a: lda SQUARE1_HIGH,x          
mnd_sm4a: sbc SQUARE2_HIGH,x          
      sta mnd_AA+1-mnd+MULT_WITH_NORMAL_DISTANCE

      ; Perform >T1_hi * <MULTIPLICAND = CCcc
      sec                          
mnd_sm1b: lda SQUARE1_LOW,x             
mnd_sm2b: sbc SQUARE2_LOW,x             
      sta mnd_cc+1-mnd+MULT_WITH_NORMAL_DISTANCE
mnd_sm3b: lda SQUARE1_HIGH,x             
mnd_sm4b: sbc SQUARE2_HIGH,x             
      sta mnd_CC+1-mnd+MULT_WITH_NORMAL_DISTANCE

      ; Perform <T1 * >MULTIPLICAND = BBbb
      ldx MULTIPLICAND+1
      sec                       
mnd_sm5a: lda SQUARE1_LOW,x          
mnd_sm6a: sbc SQUARE2_LOW,x          
      sta mnd_bb+1-mnd+MULT_WITH_NORMAL_DISTANCE
mnd_sm7a: lda SQUARE1_HIGH,x          
mnd_sm8a: sbc SQUARE2_HIGH,x          
      sta mnd_BB+1-mnd+MULT_WITH_NORMAL_DISTANCE

      ; Perform >T1 * >MULTIPLICAND = DDdd
      sec                       
mnd_sm5b: lda SQUARE1_LOW,x          
mnd_sm6b: sbc SQUARE2_LOW,x          
      sta mnd_dd+1-mnd+MULT_WITH_NORMAL_DISTANCE
mnd_sm7b: lda SQUARE1_HIGH,x          
mnd_sm8b: sbc SQUARE2_HIGH,x          
      sta PRODUCT+3             

      ; Add the separate multiplications together
      clc                                        
mnd_AA:  lda #0                                     
mnd_bb:  adc #0                                     
      sta PRODUCT+1                              
mnd_BB:  lda #0                                     
mnd_CC:  adc #0                                     
      sta PRODUCT+2                              
;      bcc mnd_skip_product3_first
; SPEED: no need to do PRODUCT+3
;      inc PRODUCT+3                          
;      clc                                    
;mnd_skip_product3_first:                                          
mnd_cc:  lda #0                                     
      adc PRODUCT+1                              
      sta PRODUCT+1                              
mnd_dd:  lda #0                                     
      adc PRODUCT+2                              
      sta PRODUCT+2
; SPEED: no need to do PRODUCT+3
;      bcc mnd_skip_product3_second
;      inc PRODUCT+3                          
;mnd_skip_product3_second:

; SPEED: can we avoid putting x on the stack?
    plx

      rts
end_of_multply_with_normal_distance_16bits:




setup_multiply_with_looking_dir_sine_16bit:

    lda LOOKING_DIR_SINE+0         
    sta mls_sm1a+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm3a+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm5a+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm7a+1-mls+MULT_WITH_LOOK_DIR_SINE
    eor #$ff         
    sta mls_sm2a+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm4a+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm6a+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm8a+1-mls+MULT_WITH_LOOK_DIR_SINE
    lda LOOKING_DIR_SINE+1         
    sta mls_sm1b+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm3b+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm5b+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm7b+1-mls+MULT_WITH_LOOK_DIR_SINE
    eor #$ff         
    sta mls_sm2b+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm4b+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm6b+1-mls+MULT_WITH_LOOK_DIR_SINE
    sta mls_sm8b+1-mls+MULT_WITH_LOOK_DIR_SINE
    
    rts
  
multply_with_looking_dir_sine_16bits:
mls:
; SPEED: can we avoid putting x on the stack?
    phx
    
      ; Perform <T1 * <MULTIPLICAND = AAaa
      ldx MULTIPLICAND+0
      sec
mls_sm1a: lda SQUARE1_LOW,x
mls_sm2a: sbc SQUARE2_LOW,x
; SPEED: do we need PRODUCT+0?
      sta PRODUCT+0             
mls_sm3a: lda SQUARE1_HIGH,x          
mls_sm4a: sbc SQUARE2_HIGH,x          
      sta mls_AA+1-mls+MULT_WITH_LOOK_DIR_SINE

      ; Perform >T1_hi * <MULTIPLICAND = CCcc
      sec                          
mls_sm1b: lda SQUARE1_LOW,x             
mls_sm2b: sbc SQUARE2_LOW,x             
      sta mls_cc+1-mls+MULT_WITH_LOOK_DIR_SINE
mls_sm3b: lda SQUARE1_HIGH,x             
mls_sm4b: sbc SQUARE2_HIGH,x             
      sta mls_CC+1-mls+MULT_WITH_LOOK_DIR_SINE

      ; Perform <T1 * >MULTIPLICAND = BBbb
      ldx MULTIPLICAND+1
      sec                       
mls_sm5a: lda SQUARE1_LOW,x          
mls_sm6a: sbc SQUARE2_LOW,x          
      sta mls_bb+1-mls+MULT_WITH_LOOK_DIR_SINE
mls_sm7a: lda SQUARE1_HIGH,x          
mls_sm8a: sbc SQUARE2_HIGH,x          
      sta mls_BB+1-mls+MULT_WITH_LOOK_DIR_SINE

      ; Perform >T1 * >MULTIPLICAND = DDdd
      sec                       
mls_sm5b: lda SQUARE1_LOW,x          
mls_sm6b: sbc SQUARE2_LOW,x          
      sta mls_dd+1-mls+MULT_WITH_LOOK_DIR_SINE
mls_sm7b: lda SQUARE1_HIGH,x          
mls_sm8b: sbc SQUARE2_HIGH,x          
      sta PRODUCT+3             

      ; Add the separate multiplications together
      clc                                        
mls_AA:  lda #0                                     
mls_bb:  adc #0                                     
      sta PRODUCT+1                              
mls_BB:  lda #0                                     
mls_CC:  adc #0                                     
      sta PRODUCT+2                              
;      bcc mls_skip_product3_first
; SPEED: no need to do PRODUCT+3
;      inc PRODUCT+3                          
;      clc                                    
;mls_skip_product3_first:                                          
mls_cc:  lda #0                                     
      adc PRODUCT+1                              
      sta PRODUCT+1                              
mls_dd:  lda #0                                     
      adc PRODUCT+2                              
      sta PRODUCT+2
; SPEED: no need to do PRODUCT+3
;      bcc mls_skip_product3_second
;      inc PRODUCT+3                          
;mls_skip_product3_second:

; SPEED: can we avoid putting x on the stack?
    plx

      rts
end_of_multply_with_looking_dir_sine_16bits:



setup_multiply_with_looking_dir_cosine_16bit:

    lda LOOKING_DIR_COSINE+0         
    sta mlc_sm1a+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm3a+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm5a+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm7a+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    eor #$ff         
    sta mlc_sm2a+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm4a+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm6a+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm8a+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    lda LOOKING_DIR_COSINE+1         
    sta mlc_sm1b+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm3b+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm5b+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm7b+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    eor #$ff         
    sta mlc_sm2b+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm4b+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm6b+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    sta mlc_sm8b+1-mlc+MULT_WITH_LOOK_DIR_COSINE
    
    rts
  
multply_with_looking_dir_cosine_16bits:
mlc:
; SPEED: can we avoid putting x on the stack?
    phx
    
      ; Perform <T1 * <MULTIPLICAND = AAaa
      ldx MULTIPLICAND+0
      sec
mlc_sm1a: lda SQUARE1_LOW,x
mlc_sm2a: sbc SQUARE2_LOW,x
; SPEED: do we need PRODUCT+0?
      sta PRODUCT+0             
mlc_sm3a: lda SQUARE1_HIGH,x          
mlc_sm4a: sbc SQUARE2_HIGH,x          
      sta mlc_AA+1-mlc+MULT_WITH_LOOK_DIR_COSINE

      ; Perform >T1_hi * <MULTIPLICAND = CCcc
      sec                          
mlc_sm1b: lda SQUARE1_LOW,x             
mlc_sm2b: sbc SQUARE2_LOW,x             
      sta mlc_cc+1-mlc+MULT_WITH_LOOK_DIR_COSINE
mlc_sm3b: lda SQUARE1_HIGH,x             
mlc_sm4b: sbc SQUARE2_HIGH,x             
      sta mlc_CC+1-mlc+MULT_WITH_LOOK_DIR_COSINE

      ; Perform <T1 * >MULTIPLICAND = BBbb
      ldx MULTIPLICAND+1
      sec                       
mlc_sm5a: lda SQUARE1_LOW,x          
mlc_sm6a: sbc SQUARE2_LOW,x          
      sta mlc_bb+1-mlc+MULT_WITH_LOOK_DIR_COSINE
mlc_sm7a: lda SQUARE1_HIGH,x          
mlc_sm8a: sbc SQUARE2_HIGH,x          
      sta mlc_BB+1-mlc+MULT_WITH_LOOK_DIR_COSINE

      ; Perform >T1 * >MULTIPLICAND = DDdd
      sec                       
mlc_sm5b: lda SQUARE1_LOW,x          
mlc_sm6b: sbc SQUARE2_LOW,x          
      sta mlc_dd+1-mlc+MULT_WITH_LOOK_DIR_COSINE
mlc_sm7b: lda SQUARE1_HIGH,x          
mlc_sm8b: sbc SQUARE2_HIGH,x          
      sta PRODUCT+3             

      ; Add the separate multiplications together
      clc                                        
mlc_AA:  lda #0                                     
mlc_bb:  adc #0                                     
      sta PRODUCT+1                              
mlc_BB:  lda #0                                     
mlc_CC:  adc #0                                     
      sta PRODUCT+2                              
;      bcc mlc_skip_product3_first
; SPEED: no need to do PRODUCT+3
;      inc PRODUCT+3                          
;      clc                                    
;mlc_skip_product3_first:                                          
mlc_cc:  lda #0                                     
      adc PRODUCT+1                              
      sta PRODUCT+1                              
mlc_dd:  lda #0                                     
      adc PRODUCT+2                              
      sta PRODUCT+2
; SPEED: no need to do PRODUCT+3
;      bcc mlc_skip_product3_second
;      inc PRODUCT+3                          
;mlc_skip_product3_second:

; SPEED: can we avoid putting x on the stack?
    plx

      rts
end_of_multply_with_looking_dir_cosine_16bits:




copy_multipliers_to_ram:

    ; Copying generate_multiplication_tables -> GENERATE_MULT_TABLES
    
    ldy #0
copy_generate_multiplication_tables_to_ram_byte:
    lda generate_multiplication_tables, y
    sta GENERATE_MULT_TABLES, y
    iny 
    cpy #(end_of_generate_multiplication_tables-generate_multiplication_tables)
    bne copy_generate_multiplication_tables_to_ram_byte

    ; Copying multply_with_normal_distance_16bits -> MULT_WITH_NORMAL_DISTANCE
    
    ldy #0
copy_multiply_with_normal_distance_to_ram_byte:
    lda multply_with_normal_distance_16bits, y
    sta MULT_WITH_NORMAL_DISTANCE, y
    iny 
    cpy #(end_of_multply_with_normal_distance_16bits-multply_with_normal_distance_16bits)
    bne copy_multiply_with_normal_distance_to_ram_byte
    
    ; Copying multply_with_looking_dir_sine_16bits -> MULT_WITH_LOOK_DIR_SINE
    
    ldy #0
copy_multply_with_looking_dir_sine_to_ram_byte:
    lda multply_with_looking_dir_sine_16bits, y
    sta MULT_WITH_LOOK_DIR_SINE, y
    iny 
    cpy #(end_of_multply_with_looking_dir_sine_16bits-multply_with_looking_dir_sine_16bits)
    bne copy_multply_with_looking_dir_sine_to_ram_byte
    
    ; Copying multply_with_looking_dir_cosine_16bits -> MULT_WITH_LOOK_DIR_COSINE
    
    ldy #0
copy_multply_with_looking_dir_cosine_to_ram_byte:
    lda multply_with_looking_dir_cosine_16bits, y
    sta MULT_WITH_LOOK_DIR_COSINE, y
    iny 
    cpy #(end_of_multply_with_looking_dir_cosine_16bits-multply_with_looking_dir_cosine_16bits)
    bne copy_multply_with_looking_dir_cosine_to_ram_byte

    rts
