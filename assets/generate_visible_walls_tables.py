# To install pygame: pip install pygame      (my version: pygame-2.1.2)
import pygame

nr_of_sqaures_horizontal = 16
nr_of_sqaures_vertical = 16
grid_size = 32
background_color = (100,100,100)
wall_grid_color = (0,0,150)

def run():
    pygame.init()

    screen_width = grid_size*nr_of_sqaures_horizontal
    screen_height = grid_size*nr_of_sqaures_vertical

    screen = pygame.display.set_mode((screen_width, screen_height))
    clock = pygame.time.Clock()

    running = True

    while running:
        # TODO: We might want to set this to max?
        clock.tick(60)

        for event in pygame.event.get():

            if event.type == pygame.QUIT: 
                running = False

            #if event.type == pygame.MOUSEMOTION: 
            #    newrect.center = event.pos

        screen.fill(background_color)
        
        map = get_map()

        for y in range(nr_of_sqaures_vertical):
            for x in range(nr_of_sqaures_horizontal):
                if (map[y][x]):
                    border_width = 0
                else:
                    border_width = 1
                pygame.draw.rect(screen, wall_grid_color, pygame.Rect(x*grid_size, y*grid_size, grid_size, grid_size), width=border_width)
     
        pygame.display.update()

    pygame.quit()

def get_map():
    return [
        [ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 ],
        [ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ],
    ]
    
run()