// -*- javascript -*-
// coding: utf-8
//        Processing.js example sketch



class StripeChooser
{
    int x,y,w,h;
    StripeChooser(int x_,int y_,int width, int height)
    {
        x = x_;
        y = y_;
        w = width;
        h = height;
    }
    void draw(var colors,var patterns)
    {
        var binwidth = w / patterns.length();
        var binheight = h / colors.length();
        stroke(0);
        for(int i=0;i<patterns.length();i++){
            for(int j=0;j<colors.length();j++){
                if ( patterns[i] == j ){
                    var c = colors[patterns[i]];
                    fill(c[0],c[1],c[2]);
                }
                else{
                    fill(0,0,100);
                }
                rect(binwidth*i+x,binheight*j+y,binwidth,binheight);
            }
        }
    }
    int mousePressed(var colors, var patterns)
    {
        var binwidth = w / patterns.length();
        var binheight = h / colors.length();
        int ix = ( mouseX - x ) / binwidth;
        int iy = ( mouseY - y ) / binheight;
        ix = (int)ix;
        iy = (int)iy;
        if ( ( 0 <= ix ) && ( ix < patterns.length() ) &&
             (0 <= iy ) && (iy < colors.length() )){
            patterns[ix] = iy;
            return 1;
        }
        return 0;
    }        
};


class ColorChooser
{
    int x,y,w,h;
    ColorChooser(int x_,int y_,int w_,int h_)
    {
        x = x_;
        y = y_;
        w = w_;
        h = h_;
    }
    void draw(var col)
    {
        PImage hue = createImage(100,1,ARGB);
        PImage sat = createImage(100,1,ARGB);
        PImage bri = createImage(100,1,ARGB);
        //hue bar
        for(int i=0;i<100;i++){
            color c;
            c = color(i,col[1],col[2]);
            hue.pixels[i] = c;
        }
        //saturation bar
        for(int i=0;i<100;i++){
            color c;
            c = color(col[0],i,col[2]);
            sat.pixels[i] = c;
        }
        //brightness bar
        for(int i=0;i<100;i++){
            color c;
            c = color(col[0],col[1],i);
            bri.pixels[i] = c;
        }
        var barheight = h / 3.3;
        pushMatrix();
        translate(x,y);
        scale(w/100,barheight);
        fill(255);
        image(hue,0,0);
        image(sat,0,1);
        image(bri,0,2);
        popMatrix();
        fill(100,0,100,100);
        stroke(0);
        for(int i=0;i<3;i++){
            beginShape();
            vertex(col[i]*w/100+x,y+barheight*(i+0.5));
            vertex(col[i]*w/100+x-barheight/3,y+barheight*i);
            vertex(col[i]*w/100+x+barheight/3,y+barheight*i);
            endShape(CLOSE);
        }

        textSize(barheight*0.7);
        fill(100,0,0,100);
        textAlign(CENTER);
        text((int)(col[0]*3.6),x+w/2+1,y+barheight*0.8+1);
        text((int)col[1],x+w/2+1,y+barheight*1.8+1);
        text((int)col[2],x+w/2+1,y+barheight*2.8+1);
        textAlign(LEFT);
        text("色",x+1,y+1+barheight*0.8);
        text("彩",x+1,y+1+barheight*1.8);
        text("明",x+1,y+1+barheight*2.8);
        fill(100,0,100,100);
        textAlign(CENTER);
        text((int)(col[0]*3.6),x+w/2,y+barheight*0.8);
        text((int)col[1],x+w/2,y+barheight*1.8);
        text((int)col[2],x+w/2,y+barheight*2.8);
        textAlign(LEFT);
        text("色",x,y+barheight*0.8);
        text("彩",x,y+barheight*1.8);
        text("明",x,y+barheight*2.8);
    }
    int mousePressed(var col, int select)
    {
        var barheight = h / 3.3;
        if (( x < mouseX) && ( mouseX <= x+w ) ){
            if ( (y < mouseY) && (mouseY <= y+barheight)  && ( select & 1 )){
                int hue = (mouseX-x)*100/w;
                col[0] = hue;
                return 1;
            }
            else if ( (y+barheight < mouseY) && (mouseY <= y+barheight*2) && ( select & 2 )  ){
                int sat = (mouseX-x)*100/w;
                col[1] = sat;
                return 2;
            }
            else if ( (y+barheight*2 < mouseY) && (mouseY <= y+barheight*3) && ( select & 4 )  ){
                int bri = (mouseX-x)*100/w;
                col[2] = bri;
                return 4;
            }
        }
        return 0;
    }
        
};


colors = [];
colors[1] = [5,100,80];
colors[0] = [10,40,80];
colors[2] = [0,0,0];
colors[3] = [0,0,100];

var patterns = [1,1,1,1,1,1,1,3,1,3,1,1,1,1,1,1,1,2,2,2,0,0,0,0,0,0,2,0,0,0,0,0,0,2,2,2];
var winx = 576;
var panelsize = winx/2;
var winy = 576;
var margin = winx/40;
var cntlheight = winx/2-margin-2;
var barheight = cntlheight / colors.length();
StripeChooser sc = new StripeChooser(0,panelsize+margin,panelsize,cntlheight);
var cc = new Array(4);
for(int i=0;i<colors.length(); i++){
    cc[i] = new ColorChooser(panelsize,panelsize+margin+i*barheight,panelsize,barheight);
}
int colorChanged = 1;

void setup() {
    noStroke(0);
    fill(0);
    textSize(barheight*0.6);
    textAlign(CENTER);
    frameRate(24);
    colorMode(HSB, 100);
    size(576,576);
}




PImage createPattern(var colors, var patterns, int sup)
{
    PImage pattern = createImage(patterns.length()*sup, patterns.length()*sup,ARGB);
    int L = 0;
    for(int i=0; i<patterns.length()*sup;i++){
        for(int j=0; j<patterns.length()*sup;j++){
            int k = (i+j) % 4;
            int  p;
            float ratio;
            if ( k < 2 ){
                p = patterns[(int)(i/sup)];
                ratio = 90 - random(10);
            }
            else{
                p = patterns[(int)(j/sup)];
                ratio = 110 + random(10);
            }
            var c = colors[p];
            float bri = c[2] * ratio / 100;
            if ( bri > 100 ) bri = 100;
            pattern.pixels[L] = color(c[0],c[1],bri,100);
            L ++;
        }
    }
    return pattern;
}


int pressedColor = 0;
int pressedBar = 0;
int divi = 4;

void mousePressed()
{
    colorChanged = 0;
    colorChanged += sc.mousePressed(colors, patterns);
    for(int i=0;i<colors.length();i++){
        pressedBar = cc[i].mousePressed(colors[i],7);
        if ( pressedBar ){
            pressedColor = i;
            colorChanged += 1;
            break;
        }
    }
    if ( ( panelsize <= mouseX ) && ( mouseX < panelsize*2 ) &&
         ( 0 <= mouseY ) && ( mouseY < panelsize ) ){
        divi = divi * 2;
        if ( divi == 16 ){
            divi = 1;
        }
        colorChanged = 1;
    }
    loop();
}


void mouseDragged()
{
    colorChanged = 0;
    if ( pressedBar ){
        colorChanged += cc[pressedColor].mousePressed(colors[pressedColor],pressedBar);
    }
    loop();
}

void mouseReleased()
{
    noLoop();
}


void draw() {
    if ( colorChanged ){
        background(100,0,100);
        fill(255);
        
        PImage pattern4 = createPattern(colors,patterns,8/divi);
        PImage pattern8 = createPattern(colors,patterns,8);
        pushMatrix();
        scale(panelsize/(patterns.length()*8));
        image(pattern8,0,0);
        popMatrix();
        for(int i=0;i<divi;i++){
            for(int j=0;j<divi;j++){
                pushMatrix();
                translate(panelsize*(1+i/divi),panelsize*(j/divi));
                scale(panelsize/(pattern4.width*divi));
                image(pattern4,0,0);
                popMatrix();
            }
        }
        colorChanged = 0;
    }
    sc.draw(colors,patterns);
    for(int i=0;i<colors.length();i++){
        cc[i].draw(colors[i]);
    }
}
