#include <stdio.h>

// Can be run online quickly: https://www.onlinegdb.com/online_c_compiler

/* Current output when run:

View width 304 px
View height 152 px
Minimum distance (fixed) 0.343750 
Focal length (fixed) 0.339844 
Face distance 44800.000000 
Half view 152 px
Scale 0.003159 
Height numerator 211968 
Min Height div 7

*/


// From WL_MAIN.C

#define FOCALLENGTH     (0x5700l)               // in global coordinates             --> 0.340

#define VIEWGLOBAL      0x10000                 // globals visable flush to wall     --> 1.00

#define VIEWWIDTH       256                     // size of view window
#define VIEWHEIGHT      144

// From WL_DEF.H

#define HEIGHTRATIO     0.50            // also defined in id_mm.c

#define PLAYERSIZE      MINDIST         // player radius

#define GLOBAL1         (1l<<16)        //                                          --> 1.00
#define TILEGLOBAL      GLOBAL1         //                                          --> 1.00
#define PIXGLOBAL       (GLOBAL1/64)        //                                      --> 1.00 / 64

#define TILESHIFT              16l      // 16 bits shift to the left

#define MINDIST         (0x5800l)       //                                          --> 0.344

#define MAXSCALEHEIGHT  256                     // largest scale on largest view

#define MAXVIEWWIDTH            320

int                     viewsize;

// This should somewhere be defined, cant find it
typedef int boolean;
#define true 1
#define false 0

typedef long fixed;

//
// projection variables
//
fixed           focallength;
int             viewwidth;
int             viewheight;
fixed           scale, maxslope;
long            heightnumerator;
int             minheightdiv;






/*
====================
=
= CalcProjection
=
= Uses focallength
=
====================
*/

void CalcProjection (long focal)
{
    int     i;
    long    intang;
    float   angle;
    double  tang;
    double  planedist;
    double  globinhalf;
    int     halfview;
    double  halfangle,facedist;

    focallength = focal;
    facedist = focal+MINDIST;
    halfview = viewwidth/2;                                 // half view in pixels

    printf("Minimum distance (fixed) %f \n", (double)(MINDIST >> 16) + (double)(MINDIST & 0x0000ffff)/(double)(256*256));
    printf("Focal length (fixed) %f \n", (double)(focallength >> 16) + (double)(focallength & 0x0000ffff)/(double)(256*256));
    printf("Face distance %f \n", facedist);
    printf("Face distance (fixed) %f \n", (double)((long)facedist >> 16) + (double)((long)facedist & 0x0000ffff)/(double)(256*256));
    printf("Half view %d px\n", halfview);

    //
    // calculate scale value for vertical height calculations
    // and sprite x calculations
    //
    scale = halfview*facedist/(VIEWGLOBAL/2);

    printf("Scale %f \n", (double)(scale >> 16) + (double)(scale & 0x0000ffff)/(double)(256*256));
    
    //
    // divide heightnumerator by a posts distance to get the posts height for
    // the heightbuffer.  The pixel height is height>>2
    //
    heightnumerator = (TILEGLOBAL*scale)>>6;
    minheightdiv = heightnumerator/0x7fff +1;

    printf("Height numerator %ld \n", heightnumerator);
    printf("Min Height div %d \n", minheightdiv);
    
    // ...
        
    // From WL_DRAW.C : CalcHeight()
        
    //
    // calculate height (heightnumerator/(nx>>8))
    //
        
    /*
        
        int     transheight;
        int ratio;
        fixed gxt,gyt,nx,ny;
        long    gx,gy;

        gx = xintercept-viewx;
        gxt = FixedByFrac(gx,viewcos);

        gy = yintercept-viewy;
        gyt = FixedByFrac(gy,viewsin);

        nx = gxt-gyt;

      //
      // calculate perspective ratio (heightnumerator/(nx>>8))
      //
        if (nx<mindist)
                nx=mindist;                     // don't let divide overflow

        asm     mov     ax,[WORD PTR heightnumerator]
        asm     mov     dx,[WORD PTR heightnumerator+2]
        asm     idiv    [WORD PTR nx+1]                 // nx>>8
    */
    
    
    
    // NOTE: We are assuming that a single TILE in the game is 1.0 global units big (=TILEGLOBAL)
    // This would mean that -when looking at a wall from a distance of one tile- the wall would be this high:
    
    // 211968 / 1.0 * 256 = 828 px ??
    // BUT this does not yet make sence! This cannot be an entry into a 256-entry table!
    
    
}
        

boolean SetViewSize (unsigned width, unsigned height)
{

    viewwidth = width&~15;                  // must be divisable by 16
    viewheight = height&~1;                 // must be even

    printf("View width %d px\n", width);
    printf("View height %d px\n", height);
    
    //
    // calculate trace angles and projection constants
    //
    CalcProjection (FOCALLENGTH);

    //
    // build all needed compiled scalers
    //
    //      MM_BombOnError (false);
    // TODO: SetupScaling (viewwidth*1.5);
    return true;
}

void NewViewSize (int width)
{
        viewsize = width;
        SetViewSize (width*16,width*16*HEIGHTRATIO);
}


void InitGame (void)
{
    // ...
    
    NewViewSize (viewsize);

}

int main()
{
    
    //viewsize = 15;   // default from ReadConfig()
    viewsize = 19;   // 304 width, 152 height, right?
    
    InitGame();

    return 0;
}
