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