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
front_wall_cone_color = (200,200,0)
back_wall_cone_color = (0,200,200)


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

texture_index_to_name = {
    0 : 'BS1',
    1 : 'BS2',
    2 : 'CLD',   # FIXME! We want to use DRF!
    3 : 'BS1',   # FIXME! We want to use DRS!
}

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
    
    starting_viewpoint_x = 7.5
    starting_viewpoint_y = 2.5
    
    all_walls = determine_walls_and_doors(map_info, map_width, map_height)
    
    for index, wall in enumerate(all_walls):
        wall['global_index'] = index
    
    for viewpoint_y_abs in range(16):
        for viewpoint_x_abs in range(16):
            viewpoint_x = viewpoint_x_abs # + 0.5
            viewpoint_y = viewpoint_y_abs # + 0.5
        
            # We need to empty 'is_behind_these_walls' from each wall, after a change in viewpoint
            for wall in all_walls:
                wall['is_behind_these_walls'] = {}
                
            # FIXME: we should use the *index* of the *set of walls* of a sections.
            #       IDEA: what if each viewpoint position (and thus a set of ordered walls) can 'access' two sets of (max 128) walls. 
            #                 Section 1: A, C  (A = wall set A, C = wall set C)
            #                 Section 2: A, B
            #                 Section 3: C, B
            #             When the ordered walls are looped through, we check the (global)index if its <> 128. 
            #             We make sure that we get the walls from the correct set (by setting a base address) and offset it by 128 if needed
            #        BIG QUESTION: how do you divide the sections the correct way?
            
            # Filtering out walls that are 'inverted' (never visible from this viewpoint)
            potentially_visible_walls = filter_out_inverted_walls(viewpoint_x, viewpoint_y, all_walls)
            mark_which_walls_are_behind_which_walls(viewpoint_x, viewpoint_y, potentially_visible_walls)
            ordered_walls = order_walls_for_viewpoint(viewpoint_x, viewpoint_y, potentially_visible_walls, all_walls)
            
            dump_ordered_walls_as_asm(ordered_walls, viewpoint_x, viewpoint_y)
    
    dump_wall_info_as_asm(all_walls, starting_viewpoint_x, starting_viewpoint_y)
    
    current_ordered_wall_index = 0
    
        
# FIXME:
    if False:
        current_potentially_visible_wall_index = 0
        TMP_second_wall_index = 18
        
        screen.fill(background_color)
        draw_map(map_info, map_width, map_height)
        current_wall = potentially_visible_walls[current_potentially_visible_wall_index]
        draw_wall_cone(viewpoint_x, viewpoint_y, current_wall, back_wall_cone_color)
        second_wall = potentially_visible_walls[TMP_second_wall_index]
        draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, front_wall_cone_color)
        first_behind_second = first_wall_is_behind_than_second_wall(viewpoint_x, viewpoint_y, current_wall, second_wall)
        pygame.display.update()
        print(first_behind_second)
    
    
    rotating = False
    
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
    
        draw_map(map_info, map_width, map_height)
        
#        draw_walls(all_walls)
#        draw_walls(potentially_visible_walls)
#        draw_walls(potentially_visible_walls)
        
#        current_wall = potentially_visible_walls[current_potentially_visible_wall_index]
        current_wall = ordered_walls[current_ordered_wall_index]
        draw_wall_cone(viewpoint_x, viewpoint_y, current_wall, back_wall_cone_color)
        
        for wall_in_front_global_index in current_wall['is_behind_these_walls']:
            wall_in_front = all_walls[wall_in_front_global_index]
            draw_wall(wall_in_front)
        
        pygame.display.update()
        
        if rotating:
            current_ordered_wall_index += 1
        if current_ordered_wall_index >= len(ordered_walls):
            running = False
            # current_ordered_wall_index = 0
            
        time.sleep(0.5)
   
        
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
        
        # TODO: isn't there a more elegant way of doing all this?
        
        if angle_start < 0:
            angle_start += 360
        if angle_end < 0:
            angle_end += 360
            
        angle_diff = angle_end-angle_start
        if angle_diff < 0:
            angle_diff += 360
    
        # We check if the wall is the wrong way around (meaning its never visible from this viewpoint)
        # Also if we look at the wall flat on (=0) we filter it out
        if angle_diff <= 0 or angle_diff >= 180:
            continue
        
        # We store the calculated start and end angle
        wall['angle_start'] = angle_start
        wall['angle_end'] = angle_end
        
        potentially_visible_walls.append(wall)

    return potentially_visible_walls

def mark_which_walls_are_behind_which_walls(viewpoint_x, viewpoint_y, walls):

    for first_wall_index in range(len(walls)):
    
        for second_wall_index in range(first_wall_index + 1, len(walls)):
            first_wall = walls[first_wall_index]
            second_wall = walls[second_wall_index]
          
            first_behind_second = first_wall_is_behind_than_second_wall(viewpoint_x, viewpoint_y, first_wall, second_wall)
            
            #print(first_wall_index, second_wall_index, first_behind_second)
            #print(first_wall)
            #print(second_wall)
            
            if first_behind_second is None:
                # We SKIP sets of walls where we can't (directly) determine whether they are in front or behind each other
                continue
    
            if first_behind_second:
                # We mark the first wall as being behind the second wall
                first_wall['is_behind_these_walls'][second_wall['global_index']] = True
                
                #screen.fill(background_color)
                #draw_walls(walls)
                #draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, back_wall_cone_color)
                #draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, front_wall_cone_color)
                #pygame.display.update()
                #clock.tick(60)
                #time.sleep(1)
            else:
                # We mark the second wall as being behind the first wall
                second_wall['is_behind_these_walls'][first_wall['global_index']] = True
                
                #screen.fill(background_color)
                #draw_walls(walls)
                #draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, back_wall_cone_color)
                #draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, front_wall_cone_color)
                #pygame.display.update()
                #clock.tick(60)
                #time.sleep(1)

            
def wall_is_behind_this_global_wall_index(walls, all_walls, wall, global_wall_index_to_find, crumbpath, depth):
    if global_wall_index_to_find in wall['is_behind_these_walls']:
        return True
        
    # print(depth*' ', crumbpath)
    #print(depth*' ', wall['is_behind_these_walls'])

    for global_wall_index_to_check_deeper in wall['is_behind_these_walls']:
        if global_wall_index_to_check_deeper in crumbpath:
            # We have looped. We should stop here.
            # FIXME: what to do here?
            print("Looped!")
            return False
            
        check_wall = all_walls[global_wall_index_to_check_deeper]
        crumbpath_deeper = crumbpath.copy() 
        crumbpath_deeper[global_wall_index_to_check_deeper] = True
        if wall_is_behind_this_global_wall_index(walls, all_walls, check_wall, global_wall_index_to_find, crumbpath_deeper, depth+1):
            return True
            
    # FIXME: what should be the default if we don't find it? None?
    return False
        

    
    
def order_walls_for_viewpoint(viewpoint_x, viewpoint_y, walls, all_walls):
    ordered_walls = []
    
    # FIXME: we need the viewpoint to be able to contain x.5 values!

    
    # Insert sorting the walls for this viewpoint
    for wall_to_insert_index in range(len(walls)):
        wall_to_insert = walls[wall_to_insert_index]
        
        # Find place to insert it
        ordered_index_to_insert = None
        for ordered_index_to_check in range(len(ordered_walls)):
#            print(wall_to_insert_index, ordered_index_to_check)
            check_wall = ordered_walls[ordered_index_to_check]
            crumbpath = {}
            crumbpath[check_wall['global_index']] = True
            # We start with the check_wall (= wall that has already been sorted) and look if that wall is behind (recursively)
            # the wall we want to insert. If its not behind it, we keep looking further for a sorted wall that *is* behind the
            # wall we want to insert
            check_wall_behind_to_be_inserted_wall = wall_is_behind_this_global_wall_index(walls, all_walls, check_wall, wall_to_insert['global_index'], crumbpath, 0)
            if check_wall_behind_to_be_inserted_wall:
                ordered_index_to_insert = ordered_index_to_check  # the index of the to-be inserted wall is going to be the index of the checked wall (which has to be moved to make room)
                break
                
        if ordered_index_to_insert is None:
#            print('inserting at the end', len(ordered_walls))
            
            # If we didnt find a wall that was behind the wall that we want to insert (is None) we append the wall at the end
            ordered_walls.append(wall_to_insert)
        else:
        
#            print('inserting into index', ordered_index_to_insert, len(ordered_walls))

            # We take the last wall and insert it (again) at the end
            ordered_walls.append(ordered_walls[len(ordered_walls)-1])
            
            # We move all the walls behind the to be inserted wall to make room (from back to front)
            for ordered_index_to_move in range(len(ordered_walls)-1, ordered_index_to_insert, -1):
                ordered_walls[ordered_index_to_move] = ordered_walls[ordered_index_to_move-1]
            
            # We place the to-be-inserted wall into the index that was just freed
            ordered_walls[ordered_index_to_insert] = wall_to_insert
        
        # print(ordered_walls)
                
            
    
    
    if False:
        for outer_index in range(len(walls) - 1):
        
            for inner_index in range(0, len(walls) - outer_index - 1):
            
                first_wall = walls[inner_index]
                second_wall_index = inner_index+1
                second_wall = walls[second_wall_index]

                crumbpath = {}
                crumbpath[inner_index] = True
                print('---- Comparing', inner_index, 'with', second_wall_index)
                first_behind_second = wall_is_behind_this_wall_index(walls, first_wall, second_wall_index, crumbpath, 0)

                if first_behind_second:
                    print('============= First behind second!!!!')

                
                # first_behind_second = first_wall_is_behind_than_second_wall(viewpoint_x, viewpoint_y, first_wall, second_wall)

                # FIXME!
                #screen.fill(background_color)
                #draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, first_wall_cone_color)
                #draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, second_wall_cone_color)
                #pygame.display.update()
                #clock.tick(60)
                
                # FIXME: temp code!
                #if first_behind_second is None:
                #    draw_wall_cone(viewpoint_x, viewpoint_y, first_wall, first_wall_cone_color)
                #    draw_wall_cone(viewpoint_x, viewpoint_y, second_wall, second_wall_cone_color)
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
    
    # TODO: is there a more elegant way to do this?
    
    # Making sure the angles are within 0 and 360 degrees
    if normalized_angle_start_first_wall < 0:
        normalized_angle_start_first_wall += 360
    if normalized_angle_end_first_wall < 0:
        normalized_angle_end_first_wall += 360
    if normalized_angle_start_second_wall < 0:
        normalized_angle_start_second_wall += 360
    if normalized_angle_end_second_wall < 0:
        normalized_angle_end_second_wall += 360
    
    # We make sure the start and end of the second wall is between -180 and 180 degrees to the normal of the start of the first wall
    if normalized_angle_start_first_wall > 180:
        normalized_angle_start_first_wall -= 360
    if normalized_angle_end_first_wall > 180:
        normalized_angle_end_first_wall -= 360
    if normalized_angle_start_second_wall > 180:
        normalized_angle_start_second_wall -= 360
    if normalized_angle_end_second_wall > 180:
        normalized_angle_end_second_wall -= 360

    #print('FIRST')
    #print(first_wall)
    #print(angle_start_first_wall, angle_end_first_wall)
    #print(normalized_angle_start_first_wall, normalized_angle_end_first_wall)
    #print('SECOND')
    #print(second_wall)
    #print(angle_start_second_wall, angle_end_second_wall)
    #print(normalized_angle_start_second_wall, normalized_angle_end_second_wall)
    

    
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
        normal_distance = wall['x_start'] - viewpoint_x
        normalized_angle = angle + 270

    if normalized_angle > 360:
        normalized_angle -= 360
    distance_over_wall = normal_distance*math.tan((normalized_angle/360)*math.pi*2)

    distance = math.sqrt(normal_distance*normal_distance + distance_over_wall*distance_over_wall)

    return distance

    
def draw_wall_cone(viewpoint_x, viewpoint_y, wall, wall_cone_color):
    
    viewpoint = (viewpoint_x*grid_size, screen_height-viewpoint_y*grid_size)
    start_point = (wall['x_start']*grid_size, screen_height-wall['y_start']*grid_size)
    end_point = (wall['x_end']*grid_size, screen_height-wall['y_end']*grid_size)

    pygame.draw.polygon(screen, wall_cone_color, (viewpoint, start_point, end_point))
    
    

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
                    new_door = create_new_wall_or_door(x+0.5, y+1, x+0.5, y, DOOR_FACING_WEST)
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
                    new_door = create_new_wall_or_door(x+1-0.5, y, x+1-0.5, y+1, DOOR_FACING_EAST)
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
                    new_door = create_new_wall_or_door(x, y+0.5, x+1, y+0.5, DOOR_FACING_SOUTH)
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
                    new_door = create_new_wall_or_door(x+1, y+1-0.5, x, y+1-0.5, DOOR_FACING_NORTH)
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
    wall['is_behind_these_walls'] = {}
    
    return wall


def draw_walls(walls):
    for wall in walls:
        draw_wall(wall)
        
def draw_wall(wall):
    wall_thickness = 2
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
        pygame.draw.line(screen, door_color_line, (wall['x_start']*grid_size-wall_thickness/2, screen_height-wall['y_start']*grid_size), (wall['x_end']*grid_size-wall_thickness/2, screen_height-wall['y_end']*grid_size), width=wall_thickness)

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
        pygame.draw.line(screen, door_color_line, (wall['x_start']*grid_size+wall_thickness/2, screen_height-wall['y_start']*grid_size), (wall['x_end']*grid_size+wall_thickness/2, screen_height-wall['y_end']*grid_size), width=wall_thickness)

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
        pygame.draw.line(screen, door_color_line, (wall['x_start']*grid_size, screen_height-(wall['y_start']*grid_size-wall_thickness/2)), (wall['x_end']*grid_size, screen_height-(wall['y_end']*grid_size-wall_thickness/2)), width=wall_thickness)

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
        pygame.draw.line(screen, door_color_line, (wall['x_start']*grid_size, screen_height-(wall['y_start']*grid_size-wall_thickness/2)), (wall['x_end']*grid_size, screen_height-(wall['y_end']*grid_size-wall_thickness/2)), width=wall_thickness)
            
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

def dump_ordered_walls_as_asm(ordered_walls, viewpoint_x, viewpoint_y):

    # FIXME: add comment showing viewpoint_x:viewpoint_y!

    print('ordered_list_of_wall_indexes_'+str(int(viewpoint_x))+'_'+str(int(viewpoint_y))+':')
    
    # FIXME: OLD   ordered_list_of_global_wall_indexes = ', '.join(str(wall['global_index']) for wall in ordered_walls)
    
    ordered_global_indexes = list(str(wall['global_index']) for wall in ordered_walls)
    # NOTE: we padd until we have 63 indexes, since we also add the nr of indexes as a first byte (resulting in 64 bytes)
    ordered_list_of_global_wall_indexes = ', '.join(ordered_global_indexes + ['0'] * (63 - len(ordered_walls)))
    print('    .byte', len(ordered_walls), '; number of ordered wall indexes')
    print('    .byte', ordered_list_of_global_wall_indexes) 
    print()

            
def dump_wall_info_as_asm(all_walls, starting_viewpoint_x, starting_viewpoint_y):

    print()
    print('STARTING_PLAYER_POS_X_HIGH = ', int(starting_viewpoint_x)) 
    print('STARTING_PLAYER_POS_X_LOW = ', int((starting_viewpoint_x - int(starting_viewpoint_x))) * 256)
    print('STARTING_PLAYER_POS_Y_HIGH = ', int(starting_viewpoint_y))
    print('STARTING_PLAYER_POS_Y_LOW = ', int(starting_viewpoint_y - int(starting_viewpoint_y)) * 256)
    print()

    print('wall_info:')
    print('    .byte', len(all_walls), '; number of walls')
    
    for global_wall_index in range(len(all_walls)):
        wall = all_walls[global_wall_index]
        
        # We pack the door-coordinates into integers (in the engine this is reverted using the facing direction again)

        x_start = wall['x_start']
        x_end = wall['x_end']
        y_start = wall['y_start']
        y_end = wall['y_end']
        facing_dir = wall['facing_dir']
        
        x_start_pack = x_start
        x_end_pack = x_end
        y_start_pack = y_start
        y_end_pack = y_end

        if (facing_dir == DOOR_FACING_SOUTH):
            y_start_pack = y_start - 0.5
            y_end_pack = y_end - 0.5
        elif (facing_dir == DOOR_FACING_NORTH):
            y_start_pack = y_start + 0.5
            y_end_pack = y_end + 0.5
        elif (facing_dir == DOOR_FACING_WEST):
            x_start_pack = x_start - 0.5
            x_end_pack = x_end - 0.5
        elif (facing_dir == DOOR_FACING_EAST):
            x_start_pack = x_start + 0.5
            x_end_pack = x_end + 0.5
        
        
        print('wall_'+str(global_wall_index)+'_info:')
        print('    .byte', int(x_start_pack), ',' ,int(y_start_pack), ' ; start x, y')
        print('    .byte', int(x_end_pack), ',' ,int(y_end_pack), ' ; end x, y')
        print('    .byte', wall['facing_dir'], '     ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west (+4 for door)')
        texture_indexes = ', '.join(texture_index_to_name[texture_index] for texture_index in wall['textures'])
        print('    .byte', texture_indexes) 
        
            
            

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