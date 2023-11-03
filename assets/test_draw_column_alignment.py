# To install pygame: pip install pygame      (my version: pygame-2.1.2)
import pygame
import math
# FIXME: remove this
import time

background_color = (0,0,0)

white_color = (200,200,200)
black_color = (20,20,20)
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


column_texture = []
for i in range(64):
    if (i % 4 == 0):
        column_texture.append(yellow_color)
    elif (i % 4 == 1):
        column_texture.append(red_color)
    elif (i % 4 == 2):
        column_texture.append(green_color)
    elif (i % 4 == 3):
        column_texture.append(blue_color)


def run():


    running = True
    while running:
        # TODO: We might want to set this to max?
        clock.tick(60)
        
        for event in pygame.event.get():

            if event.type == pygame.QUIT: 
                running = False

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_UP:
                    rotating = True
                    
                if event.key == pygame.K_LEFT:
                    current_ordered_wall_index -= 1
                    print(ordered_walls[current_ordered_wall_index]['global_index'])
                if event.key == pygame.K_RIGHT:
                    current_ordered_wall_index += 1
                    print(ordered_walls[current_ordered_wall_index]['global_index'])
                    
            #if event.type == pygame.MOUSEMOTION: 
                # newrect.center = event.pos
                
        screen.fill(background_color)
        
        x = 0
        wall_height = 64
        screen_height = 152
        draw_single_wall_column(screen, x, wall_height, screen_height, column_texture)
        draw_single_wall_column_new(screen, x+1, wall_height, screen_height, column_texture)
    
        
        pygame.display.update()
        
        time.sleep(0.5)
   
        
    pygame.quit()


def draw_single_wall_column(screen, x, wall_height, screen_height, column_texture):

    # TEST: how to setup these number correctly?
    texture_row_index = 0.5  
    # increment_texture = 0.8
    increment_texture = 0.7

    for y in range(wall_height):
        # FIXME: y should be a VIRTUAL y-position and we should skip certain y-coordinates
        y_screen = y + top_border
        # FIXME: we should probably change x_screen too?
        x_screen = x + left_border
        
        pixel_color = column_texture[int(texture_row_index)]
        
        # FIXME: we are doing *6 here, which is overkill
        pygame.draw.rect(screen, pixel_color, pygame.Rect(x_screen*6, y_screen*6, 6, 6))

        # FIXME: do some form of SCALING here!!
        texture_row_index += increment_texture 
        


def draw_single_wall_column_new(screen, x, wall_height, screen_height, column_texture):

    # TEST: how to setup these number correctly?
    screen_row_index = 0.49  
    # increment_texture = 0.8
    increment_texture = 0.7
    
    increment = (1/increment_texture)/2

    texture_height = 64
    for y_texture in range(texture_height):
        # FIXME: we should probably change x_screen too?
        x_screen = x + left_border
        
        pixel_color = column_texture[y_texture]
        
        # FIXME: y should be a VIRTUAL y-position and we should skip certain y-coordinates
        y_screen = int(screen_row_index) + top_border
        # FIXME: we are doing *6 here, which is overkill
        pygame.draw.rect(screen, pixel_color, pygame.Rect(x_screen*6, y_screen*6, 6, 6))
        screen_row_index += increment 
        
        if (screen_row_index > wall_height):
            break
            
        y_screen = int(screen_row_index) + top_border
        # FIXME: we are doing *6 here, which is overkill
        pygame.draw.rect(screen, pixel_color, pygame.Rect(x_screen*6, y_screen*6, 6, 6))
        screen_row_index += increment 
        
        if (screen_row_index > wall_height):
            break
    
run()