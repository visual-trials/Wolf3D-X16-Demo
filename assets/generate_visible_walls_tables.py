# To install pygame: pip install pygame      (my version: pygame-2.1.2)
import pygame
import math

nr_of_sqaures_horizontal = 16
nr_of_sqaures_vertical = 16
grid_size = 32

background_color = (100,100,100)
bs1_wall_color = (0,0,100)
bs2_wall_color = (0,0,200)
door_color = (150,150,0)
grid_line_color = (80,80,80)
door_color_line = (180,180,0)
first_wall_cone_color = (200,200,0)
second_wall_cone_color = (0,200,200)

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

pygame.init()

pygame.display.set_caption('X16 Wold3D asset converter')
screen = pygame.display.set_mode((screen_width, screen_height))
clock = pygame.time.Clock()

def run():

    map_width = 15
    map_height = 14
    map_info = get_map_info()
    
    # FIXME: hardcoded, we should iterate through all grid elements
    viewpoint_x = 3
    viewpoint_y = 7

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
    
        draw_map(map_info, map_width, map_height)
        
        draw_walls(walls)
        
        ordered_walls = order_walls_for_viewpoint(viewpoint_x, viewpoint_y, walls)
    
        pygame.display.update()
    
        
    pygame.quit()

    
def order_walls_for_viewpoint(viewpoint_x, viewpoint_y, walls):
    ordered_walls = []
    
    # FIXME: we need the viewpoint to be able to contain x.5 values!
    
    # Bubble sorting the walls for this viewpoint
    for outer_index in range(len(walls) - 1):
    
        for inner_index in range(0, len(walls) - outer_index - 1):
        
            first_wall = walls[inner_index]
            second_wall = walls[inner_index+1]
            
            first_behind_second = first_wall_is_behind_than_second_wall(viewpoint_x, viewpoint_y, first_wall, second_wall)

            # FIXME!
            screen.fill(background_color)
            draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, True)
            draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, False)
            pygame.display.update()
            clock.tick(60)
            
            # FIXME: temp code!
            if first_behind_second is None:
                draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, True)
                draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, False)
                pygame.display.update()
                break
                
            # FIXME: enable this!
            if first_behind_second:
                # Swap the two walls in the array
                tmp_wall = walls[inner_index+1]
                walls[inner_index+1] = walls[inner_index]
                walls[inner_index] = tmp_wall
            
            # FIXME
            # break
            
        pygame.display.update()
        
        # FIXME
        # break


    
    
    return ordered_walls
    
def first_wall_is_behind_than_second_wall(viewpoint_x, viewpoint_y, first_wall, second_wall):
    # FIXME!
    # first_is_behind_second = False
    
    # FIXME: we need a more precise viewpoint_x/y!!
    
    delta_x_start_first = first_wall['x_start'] - viewpoint_x
    delta_y_start_first = first_wall['y_start'] - viewpoint_y
    delta_x_end_first = first_wall['x_end'] - viewpoint_x
    delta_y_end_first = first_wall['y_end'] - viewpoint_y
    
    delta_x_start_second = second_wall['x_start'] - viewpoint_x
    delta_y_start_second = second_wall['y_start'] - viewpoint_y
    delta_x_end_second = second_wall['x_end'] - viewpoint_x
    delta_y_end_second = second_wall['y_end'] - viewpoint_y

    # We calculate the angle from the viewpoint (looking north) as a value between 0 and 360 degrees (clockwise looking from above)
    angle_start_first_wall = math.atan2(delta_x_start_first, delta_y_start_first)/math.pi*180
    angle_end_first_wall = math.atan2(delta_x_end_first, delta_y_end_first)/math.pi*180
    angle_start_second_wall = math.atan2(delta_x_start_second, delta_y_start_second)/math.pi*180
    angle_end_second_wall = math.atan2(delta_x_end_second, delta_y_end_second)/math.pi*180
    
    # We make the angle be between 0 and 360 degrees (clockwise looking from above)
    if angle_start_first_wall < 0:
        angle_start_first_wall += 360
    if angle_end_first_wall < 0:
        angle_end_first_wall += 360
    if angle_start_second_wall < 0:
        angle_start_second_wall += 360
    if angle_end_second_wall < 0:
        angle_end_second_wall += 360

    # We check if either wall is the wrong way around (meaning its never visible from this viewpoint)
    if angle_end_first_wall-angle_start_first_wall < 0:
        # FIXME: the first wall is the wrong way around and should not be in the list of walls at all: for now we push it to the back of the list, but we should mark it as such!
        return True      

    if angle_end_second_wall-angle_start_second_wall < 0:
        # FIXME: the second wall is the wrong way around and should not be in the list of walls at all: for now we don't pull it forward of the list, but we should mark it as such!
        return False
        
    # We now normalize to the value of angle_start_first_wall
    normalized_angle_start_first_wall = angle_start_first_wall - angle_start_first_wall # = 0
    normalized_angle_end_first_wall = angle_end_first_wall - angle_start_first_wall
    normalized_angle_start_second_wall = angle_start_second_wall - angle_start_first_wall
    normalized_angle_end_second_wall = angle_end_second_wall - angle_start_first_wall
    
    walls_are_overlapping = False
    
    # We check if the start of the second wall is between the start and end of the first wall
    if (normalized_angle_start_second_wall > 0 and normalized_angle_start_second_wall < normalized_angle_end_first_wall):
        # The start of the second wall is withing the start and end of the first wall, so we have an overlap
        walls_are_overlapping = True

    # We check if the end of the second wall is between the start and end of the first wall
    if (normalized_angle_end_second_wall > 0 and normalized_angle_end_second_wall < normalized_angle_end_first_wall):
        # The end of the second wall is withing the start and end of the first wall, so we have an overlap
        walls_are_overlapping = True
        
    if not walls_are_overlapping:
        # We have no overlap, so we don't have to change the order in the list
        return False
    
    print('----')
    print(angle_start_first_wall, angle_end_first_wall)
    print(angle_start_second_wall, angle_end_second_wall)
    
    print(normalized_angle_start_first_wall, normalized_angle_end_first_wall)
    print(normalized_angle_start_second_wall, normalized_angle_end_second_wall)
    
    # FIXME: for now we want to show overlapping walls!
    return None

        
    # FIXME!

#    return first_is_behind_second
    
def draw_wall_cone(viewpoint_x, viewpoint_y, wall, is_first_wall):
    
    viewpoint = (viewpoint_x*grid_size, screen_height-viewpoint_y*grid_size)
    start_point = (wall['x_start']*grid_size, screen_height-wall['y_start']*grid_size)
    end_point = (wall['x_end']*grid_size, screen_height-wall['y_end']*grid_size)

    if is_first_wall:
        pygame.draw.polygon(screen, first_wall_cone_color, (viewpoint, start_point, end_point))
    else:
        pygame.draw.polygon(screen, second_wall_cone_color, (viewpoint, start_point, end_point))
    
    

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
                elif (map_info[y][x+1] == GRID_DOOR):
                    # We have a door square on the right and a filled sqaure on the left, so we have a east facing wall (with a door-side-texture)
                    if not current_wall:
                        # We do not have a current wall so we create one
                        current_wall = create_new_wall_or_door(x+1, y, x+1, y+1, WALL_FACING_EAST)
                        current_wall['textures'].append(TEXTURE_DRS)
                        walls.append(current_wall)
                    else:
                        # We need to add this wall segment to the current wall
                        current_wall['y_end'] = y+1
                        current_wall['textures'].append(TEXTURE_DRS)
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

    # Run through rows and determine horizontal walls/doors that are facing south
    for y in range(map_height):
        # We start a row with no current wall
        current_wall = None
        
        if (y <= 1):
            # Since we are looking for horizontal walls facting south, the first/bottom 2 rows can be skipped
            continue
            
        # Loop from low to high (for south facing walls)
        for x in range(map_width):
            # For each grid square we look if its a wall or a door
            if (is_GRID_WALL(map_info[y][x])):
                # We then look if the square to the BOTTOM of it is empty
                if (map_info[y-1][x] == GRID_EMPTY):
                    # We have a empty square on the bottom and a filled sqaure on the top, so we have a south facing wall
                    if not current_wall:
                        # We do not have a current wall so we create one
                        current_wall = create_new_wall_or_door(x, y, x+1, y, WALL_FACING_SOUTH)
                        current_wall['textures'].append(grid_code_to_texture(map_info[y][x]))
                        walls.append(current_wall)
                    else:
                        # We need to add this wall segment to the current wall
                        current_wall['x_end'] = x+1
                        current_wall['textures'].append(grid_code_to_texture(map_info[y][x]))
                elif (map_info[y-1][x] == GRID_DOOR):
                    # We have a door square on the bottom and a filled sqaure on the top, so we have a south facing wall (with a door-side-texture)
                    if not current_wall:
                        # We do not have a current wall so we create one
                        current_wall = create_new_wall_or_door(x, y, x+1, y, WALL_FACING_SOUTH)
                        current_wall['textures'].append(TEXTURE_DRS)
                        walls.append(current_wall)
                    else:
                        # We need to add this wall segment to the current wall
                        current_wall['x_end'] = x+1
                        current_wall['textures'].append(TEXTURE_DRS)
                else:
                    # We have no empty square on the bottom (anymore) so we unset the current wall
                    current_wall = None
            elif (map_info[y][x] == GRID_DOOR):
                # We have no wall (anymore) so we unset the current wall
                current_wall = None
                # We then look if the square to the bottom of it is empty
                if (map_info[y-1][x] == GRID_EMPTY):
                    # We have a empty square on the bottom and a door sqaure on the top, so we have a south facing door
                    new_door = create_new_wall_or_door(x, y, x+1, y, DOOR_FACING_SOUTH)
                    new_door['textures'].append(TEXTURE_DRF)
                    walls.append(new_door)
            else:  # Assuming its empty
                # We have no wall (anymore) so we unset the current wall
                current_wall = None
                

    # Run through rows and determine horizontal walls/doors that are facing north
    for y in range(map_height):
        # We start a row with no current wall
        current_wall = None
        
        if (y >= map_height-2):
            # Since we are looking for horizontal walls facting north, the last/top 2 rows can be skipped
            continue
            
        # Loop from high to low (for north facing walls)
        for x in range(map_width, 0, -1):
            # For each grid square we look if its a wall or a door
            if (is_GRID_WALL(map_info[y][x])):
                # We then look if the square to the TOP of it is empty
                if (map_info[y+1][x] == GRID_EMPTY):
                    # We have a empty square on the top and a filled sqaure on the top, so we have a north facing wall
                    if not current_wall:
                        # We do not have a current wall so we create one
                        current_wall = create_new_wall_or_door(x+1, y+1, x, y+1, WALL_FACING_NORTH)
                        current_wall['textures'].append(grid_code_to_texture(map_info[y][x]))
                        walls.append(current_wall)
                    else:
                        # We need to add this wall segment to the current wall
                        current_wall['x_end'] = x
                        current_wall['textures'].append(grid_code_to_texture(map_info[y][x]))
                elif (map_info[y+1][x] == GRID_DOOR):
                    # We have a door square on the top and a filled sqaure on the top, so we have a north facing wall (with a door-side-texture)
                    if not current_wall:
                        # We do not have a current wall so we create one
                        current_wall = create_new_wall_or_door(x+1, y+1, x, y+1, WALL_FACING_NORTH)
                        current_wall['textures'].append(TEXTURE_DRS)
                        walls.append(current_wall)
                    else:
                        # We need to add this wall segment to the current wall
                        current_wall['x_end'] = x
                        current_wall['textures'].append(TEXTURE_DRS)
                else:
                    # We have no empty square on the top (anymore) so we unset the current wall
                    current_wall = None
            elif (map_info[y][x] == GRID_DOOR):
                # We have no wall (anymore) so we unset the current wall
                current_wall = None
                # We then look if the square to the top of it is empty
                if (map_info[y+1][x] == GRID_EMPTY):
                    # We have a empty square on the top and a door sqaure on the top, so we have a north facing door
                    new_door = create_new_wall_or_door(x+1, y+1, x, y+1, DOOR_FACING_NORTH)
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
        return bs1_wall_color
    elif (texture == TEXTURE_BS2):
        return bs2_wall_color
    elif (texture == TEXTURE_DRF):
        return door_color
    elif (texture == TEXTURE_DRS):
        return door_color



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


def draw_walls(walls):
    wall_thickness = 2

    for wall in walls:
        if (wall['facing_dir'] == WALL_FACING_WEST):
            length_of_wall = wall['y_start']-wall['y_end']
            for y_offset_south in range(length_of_wall):
                texture = wall['textures'][y_offset_south]
                pygame.draw.line(
                    screen, 
                    texture_to_color(texture), 
                    (wall['x_start'] * grid_size, screen_height-(wall['y_start'] - y_offset_south    ) * grid_size), 
                    (wall['x_end']   * grid_size, screen_height-(wall['y_start'] - y_offset_south - 1) * grid_size), 
                    width=wall_thickness)
            
        elif (wall['facing_dir'] == DOOR_FACING_WEST):
            pygame.draw.line(screen, door_color_line, (wall['x_start']*grid_size-wall_thickness/2+grid_size/2, screen_height-wall['y_start']*grid_size), (wall['x_end']*grid_size-wall_thickness/2+grid_size/2, screen_height-wall['y_end']*grid_size), width=wall_thickness)

        if (wall['facing_dir'] == WALL_FACING_EAST):

            length_of_wall = wall['y_end']-wall['y_start']
            for y_offset_north in range(length_of_wall):
                texture = wall['textures'][y_offset_north]
                pygame.draw.line(
                    screen, 
                    texture_to_color(texture), 
                    (wall['x_start'] * grid_size, screen_height-(wall['y_start'] + y_offset_north    ) * grid_size), 
                    (wall['x_end']   * grid_size, screen_height-(wall['y_start'] + y_offset_north + 1) * grid_size), 
                    width=wall_thickness)
                    
        elif (wall['facing_dir'] == DOOR_FACING_EAST):
            pygame.draw.line(screen, door_color_line, (wall['x_start']*grid_size+wall_thickness/2-grid_size/2, screen_height-wall['y_start']*grid_size), (wall['x_end']*grid_size+wall_thickness/2-grid_size/2, screen_height-wall['y_end']*grid_size), width=wall_thickness)

        elif (wall['facing_dir'] == WALL_FACING_SOUTH):
            length_of_wall = wall['x_end']-wall['x_start']
            for x_offset_east in range(length_of_wall):
                texture = wall['textures'][x_offset_east]
                pygame.draw.line(
                    screen, 
                    texture_to_color(texture), 
                    ((wall['x_start'] + x_offset_east    ) * grid_size, screen_height-(wall['y_start'] * grid_size)), 
                    ((wall['x_start'] + x_offset_east + 1) * grid_size, screen_height-(wall['y_end'] * grid_size)), 
                    width=wall_thickness)
            
        elif (wall['facing_dir'] == DOOR_FACING_SOUTH):
            pygame.draw.line(screen, door_color_line, (wall['x_start']*grid_size, screen_height-(wall['y_start']*grid_size-wall_thickness/2+grid_size/2)), (wall['x_end']*grid_size, screen_height-(wall['y_end']*grid_size-wall_thickness/2+grid_size/2)), width=wall_thickness)

        elif (wall['facing_dir'] == WALL_FACING_NORTH):
            length_of_wall = wall['x_start']-wall['x_end']
            for x_offset_west in range(length_of_wall):
                texture = wall['textures'][x_offset_west]
                pygame.draw.line(
                    screen, 
                    texture_to_color(texture), 
                    ((wall['x_start'] - x_offset_west    ) * grid_size, screen_height-(wall['y_start'] * grid_size)), 
                    ((wall['x_start'] - x_offset_west - 1) * grid_size, screen_height-(wall['y_end'] * grid_size)), 
                    width=wall_thickness)
            
        elif (wall['facing_dir'] == DOOR_FACING_NORTH):
            pygame.draw.line(screen, door_color_line, (wall['x_start']*grid_size, screen_height-(wall['y_start']*grid_size-wall_thickness/2+grid_size/2)), (wall['x_end']*grid_size, screen_height-(wall['y_end']*grid_size-wall_thickness/2+grid_size/2)), width=wall_thickness)
            
def draw_map(map_info, map_width, map_height):

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
                
            pygame.draw.rect(screen, square_color, pygame.Rect(x*grid_size+4, (screen_height-grid_size)-y*grid_size+4, grid_size-8, grid_size-8), width=border_width)



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