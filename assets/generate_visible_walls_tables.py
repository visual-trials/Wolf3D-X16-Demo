# To install pygame: pip install pygame      (my version: pygame-2.1.2)
import pygame

nr_of_sqaures_horizontal = 16
nr_of_sqaures_vertical = 16
grid_size = 32
background_color = (100,100,100)
wall_color = (0,0,150)
door_color = (150,150,0)
grid_line_color = (50,50,50)

screen_width = grid_size*nr_of_sqaures_horizontal
screen_height = grid_size*nr_of_sqaures_vertical

def run():
    pygame.init()


    screen = pygame.display.set_mode((screen_width, screen_height))
    clock = pygame.time.Clock()

    
    map_width = 15
    map_height = 14
    map_info = get_map_info()
    print(map_info)


    # Run through columns
#    for x in range(nr_of_sqaures_horizontal):
        
    running = True
    while running:
        # TODO: We might want to set this to max?
        clock.tick(60)

        for event in pygame.event.get():

            if event.type == pygame.QUIT: 
                running = False

            #if event.type == pygame.MOUSEMOTION: 
            #    newrect.center = event.pos

        draw_map(screen, map_info, map_width, map_height)
        
        pygame.display.update()
     
    pygame.quit()


def draw_map(screen, map_info, map_width, map_height):

    screen.fill(background_color)
    
    for y in range(nr_of_sqaures_vertical):
        if (y >= map_height):
            continue
        for x in range(nr_of_sqaures_horizontal):
            if (x >= map_width):
                continue
            if (map_info[y][x] == 1):
                border_width = 0
                square_color = wall_color
            elif (map_info[y][x] == 8):
                border_width = 0
                square_color = door_color
            elif (map_info[y][x] == 0):
                border_width = 1
                square_color = grid_line_color
            pygame.draw.rect(screen, square_color, pygame.Rect(x*grid_size, (screen_height-grid_size)-y*grid_size, grid_size, grid_size), width=border_width)



def get_map_info():
    return list(reversed([
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ],
        [ 1,1,1,1,1,1,1,8,1,1,1,1,1,1,1,0 ],
        [ 1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0 ],
        [ 1,0,0,0,0,8,0,0,0,8,0,0,0,0,1,0 ],
        [ 1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0 ],
        [ 1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0 ],
        [ 1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,0 ],
        [ 1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0 ],
        [ 1,0,0,0,0,8,0,0,0,8,0,0,0,0,1,0 ],
        [ 1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0 ],
        [ 1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,0 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0 ],
        [ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0 ],
    ]))
    
run()