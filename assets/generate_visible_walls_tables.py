# To install pygame: pip install pygame      (my version: pygame-2.1.2)
import pygame

nr_of_sqaures_horizontal = 16
nr_of_sqaures_vertical = 16
grid_size = 32
background_color = (100,100,100)
wall_color = (0,0,150)
door_color = (150,150,0)
grid_line_color = (50,50,50)

west_wall_color = (0,150,150)

WALL_FACING_NORTH = 0
WALL_FACING_EAST = 1
WALL_FACING_SOUTH = 2
WALL_FACING_WEST = 3
DOOR_FACING_NORTH = 4
DOOR_FACING_EAST = 5
DOOR_FACING_SOUTH = 6
DOOR_FACING_WEST = 7

screen_width = grid_size*nr_of_sqaures_horizontal
screen_height = grid_size*nr_of_sqaures_vertical

def run():
    pygame.init()


    screen = pygame.display.set_mode((screen_width, screen_height))
    clock = pygame.time.Clock()

    
    map_width = 15
    map_height = 14
    map_info = get_map_info()

    walls = determine_walls_and_doors(map_info, map_width, map_height)
        
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
    
        draw_map(screen, map_info, map_width, map_height)
        
        draw_walls(screen, walls)
    
        pygame.display.update()
    
        
    pygame.quit()


def determine_walls_and_doors(map_info, map_width, map_height):

    walls = []

    # Run through columns and determine vertical walls that are facing west
    for x in range(map_width):
        # We start a column with no current wall
        current_west_facing_wall = None
        if (x == 0):
            # Since we are looking for vertical walls facting west, the first column can be skipped
            continue
        for y in range(map_height):
            # For each grid square we look if its a wall
            if (map_info[y][x] == 1):
                # We then look if the square to the left of it is empty
                if (map_info[y][x-1] == 0):
                    # We have a empty square on the left and a filled sqaure on the right, so we have a west facing wall
                    if not current_west_facing_wall:
                        # We do not have a current wall so we create one
                        current_west_facing_wall = create_new_wall(x, y+1, x, y, WALL_FACING_WEST)
                        walls.append(current_west_facing_wall)
                    else:
                        # We need to add this wall segment to the current wall
                        current_west_facing_wall['y_start'] = y+1
                else:
                    # We have no empty square on the left (anymore) so we unset the current wall
                    current_west_facing_wall = None
            else:
                # We have no wall (anymore) so we unset the current wall
                current_west_facing_wall = None
                
                
                
    return walls
    
    
def create_new_wall(x_start, y_start, x_end, y_end, facing_dir):
    wall = {}
    wall['x_start'] = x_start
    wall['y_start'] = y_start
    wall['x_end'] = x_end
    wall['y_end'] = y_end
    wall['facing_dir'] = facing_dir
    
    return wall


def draw_walls(screen, walls):
    wall_thickness = 2

    for wall in walls:
        if (wall['facing_dir'] == WALL_FACING_WEST):
            pygame.draw.line(screen, west_wall_color, (wall['x_start']*grid_size-wall_thickness, screen_height-wall['y_start']*grid_size), (wall['x_end']*grid_size-wall_thickness, screen_height-wall['y_end']*grid_size), width=wall_thickness)

def draw_map(screen, map_info, map_width, map_height):

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