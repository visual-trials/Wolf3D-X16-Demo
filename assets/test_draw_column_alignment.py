# To install pygame: pip install pygame      (my version: pygame-2.1.2)
import pygame
import math
# FIXME: remove this
import time

background_color = (0,0,0)

white_color = (200,200,200)
black_color = (20,20,20)
grey_color = (100,100,100)
blue_color = (0,0,200)
red_color = (200,0,0)
green_color = (20,200,20)
yellow_color = (200,200,20)
purple_color = (200,0,200)
orange_color = (200,100,0)

screen_width = 320
screen_height = 240

left_border = 25
top_border = 20

pygame.init()

pygame.display.set_caption('X16 Wold3D TEST draw column alignment')
screen = pygame.display.set_mode((screen_width*3, screen_height*3))
clock = pygame.time.Clock()

pygame.font.init()
my_font = pygame.font.SysFont('Arial', 20)

'''

Also investigating an alternative way to draw columns for Wolf3D:

- You draw from the vertical center of the screen (starting at the left most pixel-column)
- You first draw down (the bottom half of the texture) in a scaled form. 
- You then draw up (the top half of the texture) in a scaled form. 
- You use generated code for drawing the scaled columns: 139? possible wall heights
- You use a specific memory setup for this
  - In Fixed RAM you place this:
    - ZP-vars
    - Stack
    - JUMP-table
    - All 139? generated column-draw codes
    - Some start/end glue code (that switches code Banked RAM on/off)
  - In Banked RAM you put
    - Your game code (banks 1-3?)
    - All textures and sprites

Because we divided the screen in HALF we just *MIGHT* have enough room to generate wallheight-specific column-draw-code
into Fixed RAM. This will however be VERY tight! We therefore want to calculate more precisely how much room this would take.

The most compact (and fastest) code would use the FX polygon helper:
  - Set X1-position to 0
  - Set X1-increment to 0
  - This effectively turns ADDR0 into a backup address for ADDR1, so it can 
    - Return to do the other half
    - Increment to the next column  
  - Draw transparently (FX feature) to move ADDR1 one pixel upwards

Here is code that would be in each draw-column-routine:

; y = texture column (odd: top half, even: bottom half)
; a = free to use (will contain DECR-bit along the way)
; x = free to use (is used for the JUMP-table offset itself)
; RAM_BANK = texture index
; COLUMN_COUNT/INDEX = column in the 3D-part of the screen (here: nr of columns to draw, decrementing)

start:
    ldx $Axxx, y
    sta DATA
    ldx $Axxx, y
    sta DATA
    
    ...
    
    ldx $Axxx, y
    sta DATA
    
    lda #DECR_BIT
    tsb ADDR1_BANK                  ; DECR is set to 1 (if not already)
    bne go_to_next_column           ; if DECR was already 1, we have done the second half and have to move to the next column
    
    bit DATA1                       ; read from DATA1 sets ADDR1 to ADDR0
    iny                             ; switch to top half of the texture
    stz DATA1                       ; transparant write to DATA1 which moves ADDR1 one pixel upwards
    jmp start                       ; We use the same code to draw the top part of the column

go_to_next_column:

    tsb ADDR1_BANK                  ; DECR-bit is set to 0 (note: accumulator still contains #DECR_BIT!)

    dec COLUMN_COUNT
    ldy COLUMN_COUNT
    
    ldx TEXTURE_IDX_PER_COL, y      ; switch to new texture (index) by switching the RAM_BANK
    stx RAM_BANK
    
    lda TEXTURE_COL_PER_COL, y      ; switch to new texture column (1/2)
    
    ; Note: the last entry of the WALL_LEN_PER_COL will contain a 0, which has a JUMP-table entry containing a single 'rts'
    ;   -> For 304 columns we probably need TWO of these WALL_LEN_PER_COL-tables containing 152+1 entries each?
    ldx WALL_LEN_PER_COL, y
    
    tay                             ; switch to new texture column (2/2)
    bit DATA0                       ; incements ADDR0 one pixel to the right
    bit DATA1                       ; sets ADDR1 to ADDR0
    jmp (JUMP_TABLE,x)

    
ALTERNATIVES/IDEAS:
    - instead of 'go_to_next_column'-routine containing the code to go to the next column, we could do an rts (or BETTER: jump to a fixed location!)
      -> this will reduce the amount of bytes needed for this generated code!    
    - the hmp start can (sometimes) be replaced by a 'bra' (which is shorter and faster)

'''


# Calculating the amount bytes need for the generared code

# Wallheights:
#
# From Black book: 
#   "To save RAM, past size 76 only every other even size is generated (2,4,6,..,72,74,76) and (78,82,86,...,504,508,512). 
#     This trick generates only 136 scalers"
#
# HOWEVER: the math does NOT add up here!
#
# SO: From code (WL_SCALE.C)
#
#   //
#   // build the compiled scalers
#   //
#
#   stepbytwo = viewheight/2;	// save space by double stepping
# 
#   for (i=1;i<=maxscaleheight;i++)
#   {
#       BuildCompScale (i*2,&(memptr)scaledirectory[i]);
#       if (i>=stepbytwo)
#           i+= 2;
#   }
#
#  The above implies that (when maxscaleheight = 256 and viewheight = 152):
#   - Wall heights go from 2 (when i = 1) to 152 with steps of 2
#   - Wall heights go from 152 with steps of 6! (note: i++ AND i+=2 AND i is multiplied by 2)
#
#    2 - 152  : every 2 wall heights (2,4,6 .. 150,152)         -> 76 different wall heights
#  158 - 512  : every 4 wall heights (158, 164, 170 .. 506, 512) -> 60 different wall heights
#
#   => This indeed adds up to 76 + 60 = 136 scalers!
#
# ---
#
# For wall lengths we need the following code:
#
#   2 - 64   :  1 read and 1 write per HALF of the wall length (1-32 reads and writes) 
#                  -> ~16 reads and writes on average for 32 wall heights (~16+~16)*32 = 1024 * 3 bytes = 3072 code bytes
#  66 - 152  :  32 reads and HALF of the wall length of writes (33-76 writes)
#                  -> 32 reads + avg ~55 writes for 44 wall lenghts (33+~55)*44 = 3872 * 3 bytes = 11616 code bytes
# 158 - 512  :  32-16? reads and 76 writes
#                   -> 24? reads + 76 writes for 60 wall lenghts (24?+76)*60 = 6000 * 3 bytes = 18000 code bytes
#
# Total of ~32688 read and writes code bytes
#
#   FIXME: Constant code byes: 15-20 bytes? -> 136 * 20 = ~~2720 bytes ...
#


'''

Below is an investigation of whether we can use the FX line drawer to use standard generated code (not specific to each 139? wall heights)
and use "scaling-by-overwriting" pixels. The basic idea is that you setup you line drawer without ADDR1-increment (which would have been horizontal, +1), 
but with an ADDR0 increment (vertically, down +320) and set the X1-increment to something lower than 1.0 to create the desired effect (or very close to it)

This allows the generated code to fit easely into Fixed RAM while putting all textures into Banked RAM. (since VRAM is basicly full)

'''

column_texture = []
for i in range(64):
    if (i == 0):
        column_texture.append(purple_color)
    elif (i == 63):
        column_texture.append(purple_color)
    elif (i == 31):
        column_texture.append(white_color)
    elif (i == 32):
        column_texture.append(grey_color)
    elif (i % 4 == 0):
        column_texture.append(yellow_color)
    elif (i % 4 == 1):
        column_texture.append(red_color)
    elif (i % 4 == 2):
        column_texture.append(green_color)
    elif (i % 4 == 3):
        column_texture.append(blue_color)


def run():

    nr_of_wall_heights = 10

    screen_y_corrections = []
    increment_corrections = []
    for wall_height_index in range(nr_of_wall_heights):
        screen_y_corrections.append(0.000)
        increment_corrections.append(0.000)
        
    current_wall_height_index = 0

    running = True
    while running:
        # TODO: We might want to set this to max?
        clock.tick(60)
        
        for event in pygame.event.get():

            if event.type == pygame.QUIT: 
                running = False

            if event.type == pygame.KEYDOWN:
                    
                if event.key == pygame.K_LEFT:
                    current_wall_height_index -= 1
                    if current_wall_height_index < 0:
                        current_wall_height_index = 0
                if event.key == pygame.K_RIGHT:
                    current_wall_height_index += 1
                    if current_wall_height_index >= nr_of_wall_heights:
                        current_wall_height_index = nr_of_wall_heights-1
                if event.key == pygame.K_COMMA:
                    increment_corrections[current_wall_height_index] -= 0.001
                if event.key == pygame.K_PERIOD:
                    increment_corrections[current_wall_height_index] += 0.001
                if event.key == pygame.K_UP:
                    screen_y_corrections[current_wall_height_index] -= 0.005
                if event.key == pygame.K_DOWN:
                    screen_y_corrections[current_wall_height_index] += 0.005
                    
            #if event.type == pygame.MOUSEMOTION: 
                # newrect.center = event.pos
                
        screen.fill(background_color)

        for wall_height_index in range(nr_of_wall_heights):
        
            screen_y_correction = screen_y_corrections[wall_height_index]
            increment_correction = increment_corrections[wall_height_index]
            
            x = wall_height_index * 4
            # FIXME: we should create a mapping between wall_height_index and wall_height INSTEAD!
            wall_height = 76 + 4*wall_height_index
            y_screen_offset = -wall_height_index*2
            screen_height = 152
            if current_wall_height_index == wall_height_index:
                pygame.draw.rect(screen, red_color, pygame.Rect((x + left_border + 0.5)*6, 2, 4, 4))
                
            draw_single_wall_column(screen, x, y_screen_offset, wall_height, screen_height, column_texture)
            draw_single_wall_column_new(screen, x+1, y_screen_offset, wall_height, screen_height, column_texture, screen_y_correction, increment_correction)
            
        text_position_x = 20
        text_position_y = 200
        
        text_surface = my_font.render("wall_index: " + str(current_wall_height_index), True, white_color)
        screen.blit(text_surface, (text_position_x*3,text_position_y*3))
        
        text_surface = my_font.render("y_corr: " + str(screen_y_corrections[current_wall_height_index]), True, white_color)
        screen.blit(text_surface, (text_position_x*3,(text_position_y+10)*3))
        
        text_surface = my_font.render("incr_corr: " + str(increment_corrections[current_wall_height_index]), True, white_color)
        screen.blit(text_surface, (text_position_x*3,(text_position_y+20)*3))
        
        pygame.display.update()
        
        time.sleep(0.1)
   
        
    pygame.quit()


def draw_single_wall_column(screen, x, y_screen_offset, wall_height, screen_height, column_texture):

    texture_height = 64
    
    increment_texture = texture_height / wall_height
    texture_row_index = increment_texture /  2  # Note: we start at HALF of the increment, so we should end up in the middle: one half before the middle, one half after the middle of the texture

    for y in range(wall_height):
        # FIXME: y should be a VIRTUAL y-position and we should *SKIP* certain y-coordinates
        y_screen = y + top_border + y_screen_offset
        x_screen = x + left_border
        
        pixel_color = column_texture[int(texture_row_index)]
        
        # FIXME: we are doing *6 here, which is overkill
        pygame.draw.rect(screen, pixel_color, pygame.Rect(x_screen*6, y_screen*6, 6, 6))

        texture_row_index += increment_texture 
        


def draw_single_wall_column_new(screen, x, y_screen_offset, wall_height, screen_height, column_texture, screen_y_correction, increment_correction):

    texture_height = 64
    
    increment_texture = texture_height / wall_height + increment_correction
    increment = (1/increment_texture)/2
    screen_row_index = increment/2 + screen_y_correction   # Note: we start at HALF of the increment, so we should end up in the middle: one half before the middle, one half after the middle of the texture
    

    for y_texture in range(texture_height):
        # FIXME: we should probably change x_screen too?
        x_screen = x + left_border
        
        pixel_color = column_texture[y_texture]
        
        # FIXME: y should be a VIRTUAL y-position and we should skip certain y-coordinates
        y_screen = int(screen_row_index) + top_border + y_screen_offset
        # FIXME: we are doing *6 here, which is overkill
        pygame.draw.rect(screen, pixel_color, pygame.Rect(x_screen*6, y_screen*6, 6, 6))
        screen_row_index += increment 
        
        if (screen_row_index > wall_height):
            break
            
        y_screen = int(screen_row_index) + top_border + y_screen_offset
        # FIXME: we are doing *6 here, which is overkill
        pygame.draw.rect(screen, pixel_color, pygame.Rect(x_screen*6, y_screen*6, 6, 6))
        screen_row_index += increment 
        
        if (screen_row_index > wall_height):
            break
    
run()