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

pygame.init()

pygame.display.set_caption('X16 Wold3D TEST draw column alignment')
screen = pygame.display.set_mode((screen_width*3, screen_height*3))
clock = pygame.time.Clock()


column_texture = []
for i in range(64):
    if (i % 2 == 0):
        column_texture.append(yellow_color)
    else:
        column_texture.append(red_color)


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
        # FIXME: draw_column()
    
        
        pygame.display.update()
        
        time.sleep(0.5)
   
        
    pygame.quit()


def draw_single_wall_column(screen, x, wall_height, screen_height, column_texture):

    left_border = 25
    top_border = 20

    for y in range(wall_height):
        # FIXME: y should be a VIRTUAL y-position and we should skip certain y-coordinates
        y_screen = y + top_border
        # FIXME: we should probably change x_screen too?
        x_screen = x + left_border
        
        # FIXME: do some form of SCALING here!!
        row_index = y
        
        pixel_color = column_texture[row_index]
        
        # FIXME: we are doing *6 here, which is overkill
        pygame.draw.rect(screen, pixel_color, pygame.Rect(x_screen*6, y_screen*6, 6, 6))

    
    
run()