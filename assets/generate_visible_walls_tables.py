# To install pygame: pip install pygame      (my version: pygame-2.1.2)
import pygame

nr_of_sqaures_horizontal = 16
nr_of_sqaures_vertical = 16
grid_size = 32
background_color = (100,100,100)
bs1_wall_color = (0,0,100)
bs2_wall_color = (0,0,200)
door_color = (150,150,0)
grid_line_color = (50,50,50)

bs1_texture_color = (0,0,100)
bs2_texture_color = (0,0,200)
drf_texture_color = (150,150,100)
drs_texture_color = (150,150,100)

west_wall_color = (0,150,150)
west_door_color = (150,0,150)
east_wall_color = (200,150,150)
east_door_color = (150,150,200)

WALL_FACING_NORTH = 0
WALL_FACING_EAST = 1
WALL_FACING_SOUTH = 2
WALL_FACING_WEST = 3
DOOR_FACING_NORTH = 4
DOOR_FACING_EAST = 5
DOOR_FACING_SOUTH = 6
DOOR_FACING_WEST = 7

GRID_EMPTY = 0
GRID_BS1 = 1
GRID_BS2 = 2
GRID_DOOR = 8

TEXTURE_BS1 = 0  # Blue stone 1
TEXTURE_BS2 = 1  # Blue stone 2
TEXTURE_DRF = 2  # Door front
TEXTURE_DRS = 3  # Door side

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

    # Run through columns and determine vertical walls/doors that are facing west
    for x in range(map_width):
        # We start a column with no current wall
        current_wall = None
        
        if (x <= 1):
            # Since we are looking for vertical walls facting west, the first 2 columns can be skipped
            continue
            
        # Loop from high to low (for west facing walls)
        for y in range(map_height, 0, -1):
            # For each grid square we look if its a wall or a door
            if (is_GRID_WALL(map_info[y][x])):
                # We then look if the square to the LEFT of it is empty
                if (map_info[y][x-1] == GRID_EMPTY):
                    # We have a empty square on the left and a filled sqaure on the right, so we have a west facing wall
                    if not current_wall:
                        # We do not have a current wall so we create one
                        current_wall = create_new_wall_or_door(x, y+1, x, y, WALL_FACING_WEST)
                        current_wall['textures'].append(grid_code_to_texture(map_info[y][x]))
                        walls.append(current_wall)
                    else:
                        # We need to add this wall segment to the current wall
                        current_wall['y_end'] = y
                        current_wall['textures'].append(grid_code_to_texture(map_info[y][x]))
                elif (map_info[y][x-1] == GRID_DOOR):
                    # We have a door square on the left and a filled sqaure on the right, so we have a west facing wall (with a door-side-texture)
                    
                    if not current_wall:
                        # We do not have a current wall so we create one
                        current_wall = create_new_wall_or_door(x, y+1, x, y, WALL_FACING_WEST)
                        current_wall['textures'].append(TEXTURE_DRS)
                        walls.append(current_wall)
                    else:
                        # We need to add this wall segment to the current wall
                        current_wall['y_end'] = y
                        current_wall['textures'].append(TEXTURE_DRS)
                else:
                    # We have no empty square on the left (anymore) so we unset the current wall
                    current_wall = None
            elif (map_info[y][x] == GRID_DOOR):
                # We have no wall (anymore) so we unset the current wall
                current_wall = None
                # We then look if the square to the left of it is empty
                if (map_info[y][x-1] == GRID_EMPTY):
                    # We have a empty square on the left and a door sqaure on the right, so we have a west facing door
                    new_door = create_new_wall_or_door(x, y+1, x, y, DOOR_FACING_WEST)
                    new_door['textures'].append(TEXTURE_DRF)
                    walls.append(new_door)
            else:  # Assuming its empty
                # We have no wall (anymore) so we unset the current wall
                current_wall = None
                
    # Run through columns and determine vertical walls/doors that are facing east
    for x in range(map_width):
        # We start a column with no current wall
        current_wall = None
        
        if (x >= map_width-2):
            # Since we are looking for vertical walls facting east, the last 2 columns can be skipped
            continue

        # Loop from low to high (for east facing walls)
        for y in range(map_height):
            # For each grid square we look if its a wall or a door
            if (is_GRID_WALL(map_info[y][x])):
                # We then look if the square to the RIGHT of it is empty
                if (map_info[y][x+1] == GRID_EMPTY):
                    # We have a empty square on the right and a filled sqaure on the left, so we have a east facing wall
                    if not current_wall:
                        # We do not have a current wall so we create one
                        current_wall = create_new_wall_or_door(x+1, y, x+1, y+1, WALL_FACING_EAST)
                        current_wall['textures'].append(grid_code_to_texture(map_info[y][x]))
                        walls.append(current_wall)
                    else:
                        # We need to add this wall segment to the current wall
                        current_wall['y_end'] = y+1
                        current_wall['textures'].append(grid_code_to_texture(map_info[y][x]))
                else:
                    # We have no empty square on the right (anymore) so we unset the current wall
                    current_wall = None
            elif (map_info[y][x] == GRID_DOOR):
                # We have no wall (anymore) so we unset the current wall
                current_wall = None
                # We then look if the square to the right of it is empty
                if (map_info[y][x+1] == GRID_EMPTY):
                    # We have a empty square on the right and a door sqaure on the left, so we have a east facing door
                    new_door = create_new_wall_or_door(x+1, y, x+1, y+1, DOOR_FACING_EAST)
                    new_door['textures'].append(TEXTURE_DRF)
                    walls.append(new_door)
            else:  # Assuming its empty
                # We have no wall (anymore) so we unset the current wall
                current_wall = None
                


                
    return walls
    
def grid_code_to_texture(grid_code):
    if (grid_code == GRID_BS1):
        return TEXTURE_BS1
    elif (grid_code == GRID_BS2):
        return TEXTURE_BS2
    else:
        print("ERROR: unknown texture for grid code:" + grid_code)
        return None

def texture_to_color(texture):
    if (texture == TEXTURE_BS1):
        return bs1_texture_color
    elif (texture == TEXTURE_BS2):
        return bs2_texture_color
    elif (texture == TEXTURE_DRF):
        return drf_texture_color
    elif (texture == TEXTURE_DRS):
        return drs_texture_color



def is_GRID_WALL(grid_code):
    if (grid_code == GRID_BS1 or grid_code == GRID_BS2):
        return True
    else:
        return False
    
def create_new_wall_or_door(x_start, y_start, x_end, y_end, facing_dir):
    wall = {}
    wall['x_start'] = x_start
    wall['y_start'] = y_start
    wall['x_end'] = x_end
    wall['y_end'] = y_end
    wall['facing_dir'] = facing_dir
    wall['textures'] = []
    
    return wall


def draw_walls(screen, walls):
    wall_thickness = 2

    for wall in walls:
        if (wall['facing_dir'] == WALL_FACING_WEST):
            length_of_wall = wall['y_start']-wall['y_end']
            for y_offset_south in range(length_of_wall):
                texture = wall['textures'][y_offset_south]
                pygame.draw.line(
                    screen, 
                    texture_to_color(texture), 
                    (wall['x_start'] * grid_size - wall_thickness/2, screen_height-(wall['y_start'] - y_offset_south    ) * grid_size), 
                    (wall['x_end']   * grid_size - wall_thickness/2, screen_height-(wall['y_start'] - y_offset_south - 1) * grid_size), 
                    width=wall_thickness)
        elif (wall['facing_dir'] == DOOR_FACING_WEST):
            pygame.draw.line(screen, west_door_color, (wall['x_start']*grid_size-wall_thickness/2+grid_size/2, screen_height-wall['y_start']*grid_size), (wall['x_end']*grid_size-wall_thickness/2+grid_size/2, screen_height-wall['y_end']*grid_size), width=wall_thickness)

        if (wall['facing_dir'] == WALL_FACING_EAST):
            pygame.draw.line(screen, east_wall_color, (wall['x_start']*grid_size+wall_thickness/2, screen_height-wall['y_start']*grid_size), (wall['x_end']*grid_size+wall_thickness/2, screen_height-wall['y_end']*grid_size), width=wall_thickness)
        elif (wall['facing_dir'] == DOOR_FACING_EAST):
            pygame.draw.line(screen, east_door_color, (wall['x_start']*grid_size+wall_thickness/2-grid_size/2, screen_height-wall['y_start']*grid_size), (wall['x_end']*grid_size+wall_thickness/2-grid_size/2, screen_height-wall['y_end']*grid_size), width=wall_thickness)
            
def draw_map(screen, map_info, map_width, map_height):

    for y in range(nr_of_sqaures_vertical):
        if (y >= map_height):
            continue
        for x in range(nr_of_sqaures_horizontal):
            if (x >= map_width):
                continue
            if (map_info[y][x] == GRID_BS1):
                border_width = 0
                square_color = bs1_wall_color
            elif (map_info[y][x] == GRID_BS2):
                border_width = 0
                square_color = bs2_wall_color
            elif (map_info[y][x] == GRID_DOOR):
                border_width = 0
                square_color = door_color
            elif (map_info[y][x] == GRID_EMPTY):
                border_width = 1
                square_color = grid_line_color
            pygame.draw.rect(screen, square_color, pygame.Rect(x*grid_size+2, (screen_height-grid_size)-y*grid_size+2, grid_size-4, grid_size-4), width=border_width)



def get_map_info():
    return list(reversed([
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ],
        [ 1,1,2,1,2,1,1,8,1,1,1,1,1,2,1,0 ],
        [ 2,0,0,0,0,1,0,0,0,1,0,0,0,0,2,0 ],
        [ 1,0,0,0,0,8,0,0,0,8,0,0,0,0,2,0 ],
        [ 1,0,0,0,0,1,0,0,0,1,0,0,0,0,2,0 ],
        [ 2,0,0,0,0,2,0,0,0,2,0,0,0,0,2,0 ],
        [ 1,1,2,1,1,2,0,0,0,1,1,1,1,1,1,0 ],
        [ 1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0 ],
        [ 2,0,0,0,0,8,0,0,0,8,0,0,0,0,2,0 ],
        [ 1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0 ],
        [ 1,2,2,1,1,2,0,0,0,2,1,1,2,1,1,0 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0 ],
        [ 2,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0 ],
        [ 1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0 ],
        [ 1,1,2,1,1,1,2,1,1,2,1,2,1,1,1,0 ],
    ]))
    
run()