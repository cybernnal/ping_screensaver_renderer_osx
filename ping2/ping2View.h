//
//  pingView.h
//  ping
//
//  Created by tom billard on 16/03/2017.
//  Copyright © 2017 tom billard. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#define BUFSIZE 128
#define MAXX 300
#define L_CF(X, x1, x2, y1, y2) ((float)(((float)((X - x1) * (y2 - y1))) / (float)(x2 - x1)) + y1)

@interface pingView : ScreenSaverView
{
    IBOutlet id configSheet;
    IBOutlet id drawFilledShapesOption;
    IBOutlet id drawOutlinedShapesOption;
    IBOutlet id drawBothOption;
}

typedef struct      s_color
{
    float           red;
    float           green;
    float           blue;
}                   t_color;

typedef struct      s_list
{
    float           t;
    struct s_list   *next;
}                   t_list;

float get_timee(char *buf);
t_list *get_new(void);
float process_list(t_list **lst, t_list **first, float t, float *med);

@end
