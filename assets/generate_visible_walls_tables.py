# To install pygame: pip install pygame      (my version: pygame-2.1.2)
import pygame
import math
# FIXME: remove this
import time

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

    all_walls = determine_walls_and_doors(map_info, map_width, map_height)
    # FIXME: filter out walls that are 'inverted' (never visible from this viewpoint)
    potentially_visible_walls = filter_out_inverted_walls(viewpoint_x, viewpoint_y, all_walls)
    mark_which_walls_are_behind_which_walls(viewpoint_x, viewpoint_y, potentially_visible_walls)
    # ordered_walls = order_walls_for_viewpoint(viewpoint_x, viewpoint_y, potentially_visible_walls)
    
    TMP_first_wall_index = 0
    TMP_second_wall_index = 34
        
    running = True
    while running:
        # TODO: We might want to set this to max?
        clock.tick(60)
        
# FIXME
#        time.sleep(1)

        for event in pygame.event.get():

            if event.type == pygame.QUIT: 
                running = False

            #if event.type == pygame.MOUSEMOTION: 
            #    newrect.center = event.pos

        screen.fill(background_color)
    
        draw_map(map_info, map_width, map_height)
        
        draw_walls(all_walls)
        
        
        #first_wall = walls[TMP_first_wall_index]
        #second_wall = walls[TMP_second_wall_index]
        #draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, True)
        #draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, False)
        
        #first_behind_second = first_wall_is_behind_than_second_wall(viewpoint_x, viewpoint_y, first_wall, second_wall)
        #TMP_second_wall_index += 1
        #if (TMP_second_wall_index >= len(walls)):
        #    TMP_second_wall_index = 0
    
        pygame.display.update()
    
        
    pygame.quit()

def filter_out_inverted_walls(viewpoint_x, viewpoint_y, walls):
    potentially_visible_walls = []

    for wall in walls:
    
        # FIXME: we need a more precise viewpoint_x/y!!
    
        delta_x_start = wall['x_start'] - viewpoint_x
        delta_y_start = wall['y_start'] - viewpoint_y
        delta_x_end = wall['x_end'] - viewpoint_x
        delta_y_end = wall['y_end'] - viewpoint_y

        # We calculate the angle from the viewpoint (looking north) as a value between 0 and 360 degrees (clockwise looking from above)
        angle_start = math.atan2(delta_x_start, delta_y_start)/math.pi*180
        angle_end = math.atan2(delta_x_end, delta_y_end)/math.pi*180
    
        # We check if the wall is the wrong way around (meaning its never visible from this viewpoint)
        # Also if we look at the wall flat on we filter it out
        if angle_end-angle_start <= 0 or angle_end-angle_start >= 180:
            continue
        
        # We store the calculated start and end angle
        wall['angle_start'] = angle_start
        wall['angle_end'] = angle_end
        
        potentially_visible_walls.append(wall)

    return potentially_visible_walls

def mark_which_walls_are_behind_which_walls(viewpoint_x, viewpoint_y, walls):

    for first_wall_index in range(len(walls) - 1):
    
        for second_wall_index in range(first_wall_index + 1, len(walls)):
            print(first_wall_index, second_wall_index)
            first_wall = walls[first_wall_index]
            second_wall = walls[second_wall_index]
            
            first_behind_second = first_wall_is_behind_than_second_wall(viewpoint_x, viewpoint_y, first_wall, second_wall)
            
            if first_behind_second is None:
                # We SKIP sets of walls where we can't (directly) determine whether they are in front or behind each other
                continue
    
            if first_behind_second:
                screen.fill(background_color)
                draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, True)
                draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, False)
                pygame.display.update()
                clock.tick(60)
                time.sleep(1)
            else:
                screen.fill(background_color)
                draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, False)
                draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, True)
                pygame.display.update()
                clock.tick(60)
                time.sleep(1)

            # FIXME: *MARK* walls as being behind/in front of each other
            
            
    
def order_walls_for_viewpoint(viewpoint_x, viewpoint_y, walls):
    ordered_walls = []
    
    # FIXME: we need the viewpoint to be able to contain x.5 values!
    
    # Bubble sorting the walls for this viewpoint
    for outer_index in range(len(walls) - 1):
    
        for inner_index in range(0, len(walls) - outer_index - 1):
        
            first_wall = walls[inner_index]
            second_wall = walls[inner_index+1]
            
            # first_behind_second = first_wall_is_behind_than_second_wall(viewpoint_x, viewpoint_y, first_wall, second_wall)

            # FIXME!
            #screen.fill(background_color)
            #draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, True)
            #draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, False)
            #pygame.display.update()
            #clock.tick(60)
            
            # FIXME: temp code!
            #if first_behind_second is None:
            #    draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, True)
            #    draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, False)
            #    pygame.display.update()
            #    break
                
            # FIXME: enable this!
            if first_behind_second:
                # Swap the two walls in the array
                tmp_wall = walls[inner_index+1]
                walls[inner_index+1] = walls[inner_index]
                walls[inner_index] = tmp_wall
            
            # FIXME
            #break
            
        pygame.display.update()
        
        # FIXME
        break


    
    
    return ordered_walls
    
def first_wall_is_behind_than_second_wall(viewpoint_x, viewpoint_y, first_wall, second_wall):
    
    # We get the angle from the viewpoint
    angle_start_first_wall = first_wall['angle_start']
    angle_end_first_wall = first_wall['angle_end']
    angle_start_second_wall = second_wall['angle_start']
    angle_end_second_wall = second_wall['angle_end']
    
    # We make the angle be between 0 and 360 degrees (clockwise looking from above)
    if angle_start_first_wall < 0:
        angle_start_first_wall += 360
    if angle_end_first_wall < 0:
        angle_end_first_wall += 360
    if angle_start_second_wall < 0:
        angle_start_second_wall += 360
    if angle_end_second_wall < 0:
        angle_end_second_wall += 360

    # We now normalize to the value of angle_start_first_wall
    normalized_angle_start_first_wall = angle_start_first_wall - angle_start_first_wall # = 0
    normalized_angle_end_first_wall = angle_end_first_wall - angle_start_first_wall
    normalized_angle_start_second_wall = angle_start_second_wall - angle_start_first_wall
    normalized_angle_end_second_wall = angle_end_second_wall - angle_start_first_wall
    
    # We make sure the start and end of the second wall is between -180 and 180 degrees to the normal of the start of the first wall
    if normalized_angle_start_second_wall > 180:
        normalized_angle_start_second_wall -= 360
    if normalized_angle_end_second_wall > 180:
        normalized_angle_end_second_wall -= 360
    
    walls_are_overlapping = False
    
    start_is_from_first_wall = False
    start_is_from_second_wall = False
    end_is_from_first_wall = False
    end_is_from_second_wall = False
    
    # We get the largest start
    if normalized_angle_start_second_wall > normalized_angle_start_first_wall:
        largest_normalized_start_angle = normalized_angle_start_second_wall
        start_is_from_second_wall = True
    else:
        largest_normalized_start_angle = normalized_angle_start_first_wall
        start_is_from_first_wall = True
        
    # We get the smallest end
    if normalized_angle_end_second_wall < normalized_angle_end_first_wall:
        smallest_normalized_end_angle = normalized_angle_end_second_wall
        end_is_from_second_wall = True
    else:
        smallest_normalized_end_angle = normalized_angle_end_first_wall
        end_is_from_first_wall = True

    
    # If the smallest end is larger than the largest start, we have an overlap
    if smallest_normalized_end_angle > largest_normalized_start_angle:
        walls_are_overlapping = True
        
        # Take now the middle-angle between the overlapping begin and end angles.
        normalized_middle_angle = (smallest_normalized_end_angle + largest_normalized_start_angle) / 2
        
        # We need to unnormalize this middle_angle to make it an absolute angle
        middle_angle = normalized_middle_angle + angle_start_first_wall
        if middle_angle > 360:
            middle_angle -= 360
        
        # We calculate the distance to both walls given this middle angle
        distance_first_wall = calculate_distance_given_wall_and_angle(middle_angle, viewpoint_x, viewpoint_y, first_wall)
        distance_second_wall = calculate_distance_given_wall_and_angle(middle_angle, viewpoint_x, viewpoint_y, second_wall)
        
#        print('----')
#        print(angle_start_first_wall, angle_end_first_wall)
#        print(angle_start_second_wall, angle_end_second_wall)    
#        print(normalized_angle_start_first_wall, normalized_angle_end_first_wall)
#        print(normalized_angle_start_second_wall, normalized_angle_end_second_wall)

        if distance_first_wall < distance_second_wall:
            # First wall is closer, so its *not* behind the second wall
            return False
        else:
            # First wall is further, so it *is* behind the second wall
            return True
        
    else:
        # We have no overlap, so we dont know which one is behind or in front. We therefore return None`
        return None
    
    
def calculate_distance_given_wall_and_angle(angle, viewpoint_x, viewpoint_y, wall):
    distance = None
    
    # Determine the distance from the viewpoint to a wall at this angle, by doing this for the wall:
    #   - you take the normal distance (which is either delta_x or delta_y) depending on the wall facing direction
    #   - you calculate the other delta_x/y by taking the tan(angle)*normal_distance
    #   - since you now have delta_x and delta_y you can calculate the distance using square root of the square of them
    
    # FIXME: we need a more precice viewpoint_x/y!!
    
    normal_distance = None
    normalized_angle = None
    if wall['facing_dir'] == WALL_FACING_NORTH or wall['facing_dir'] == DOOR_FACING_NORTH:
        normal_distance = viewpoint_y - wall['y_start']
        normalized_angle = angle + 180
    elif wall['facing_dir'] == WALL_FACING_EAST or wall['facing_dir'] == DOOR_FACING_EAST:
        normal_distance = viewpoint_x - wall['x_start']
        normalized_angle = angle + 90
    elif wall['facing_dir'] == WALL_FACING_SOUTH or wall['facing_dir'] == DOOR_FACING_SOUTH:
        normal_distance = wall['y_start'] - viewpoint_y
        normalized_angle = angle + 0
    elif wall['facing_dir'] == WALL_FACING_WEST or wall['facing_dir'] == DOOR_FACING_WEST:
        normal_distance = wall['x_start'] = viewpoint_x
        normalized_angle = angle + 270

    if normalized_angle > 360:
        normalized_angle -= 360
    distance_over_wall = normal_distance*math.tan((normalized_angle/360)*math.pi*2)

    distance = math.sqrt(normal_distance*normal_distance + distance_over_wall*distance_over_wall)

    return distance

    
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