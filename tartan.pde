// This sketch builds on a prior work, "Tartan Designer", created by Masakazu Matsumoto
// http://studio.sketchpad.cc/sp/pad/view/ro.9jJoYPveV7jZv/rev.2210



// This sketch builds on a prior work, "Tartan Designer", created by Masakazu Matsumoto
// http://studio.sketchpad.cc/sp/pad/view/ro.9o5t14k3KfkKT/rev.3837



// This sketch builds on a prior work, "Tartan Designer", created by Masakazu Matsumoto
// http://studio.sketchpad.cc/sp/pad/view/ro.9Pyx57Qj7ymC9/rev.147



// This sketch builds on a prior work, "Tartan Designer", created by Masakazu Matsumoto
// http://studio.sketchpad.cc/sp/pad/view/ro.90jg52--oZsvf/rev.302



// -*- javascript -*-
// coding: utf-8
//        Processing.js example sketch

int BINW = 8;


class CheckBox
{
    int x,y,w,h;
    int checked;
    var label;
    CheckBox(int x_, int y_, int siz, int checked_, var label_)
    {
        x = x_;
        y = y_;
        w = siz;
        h = siz;
        checked = checked_;
        label = label_;
    }
    void draw(var colors, var patterns)
    {
        stroke(0);
        strokeWeight(1);
        fill(0,0,100);
        rect(x,y,w,h);
        if ( checked ){
            line(x,y,x+w,y+h);
            line(x+w,y,x,y+h);
        }
        fill(0);
        textAlign(LEFT);
        textSize(h*0.8);
        text(label,x+w*2, y+w*0.8);
    }
    int mousePressed()
    {
        if ( ( x < mouseX ) && ( mouseX < x+w ) &&
            (y < mouseY ) && (mouseY < y+h ) ){
            checked = ! checked;
            return 1;
        }
    }
}

class Bar
{
    int x,y,w,h,delta;
    int x0;
    Bar(int x_, int y_, int width, int height, int delta_)
    {
        x = x_;
        y = y_;
        w = width;
        h = height;
        delta = delta_;
    }
    void draw(var colors, var patterns)
    {
        fill(0,100,100);
        rect(x,y,w,h);
    }
    int mousePressed()
    {
        if ( ( x < mouseX ) && ( mouseX < x+w ) &&
            (y < mouseY ) && (mouseY < y+h ) ){
            x0 = mouseX;
        }
        else{
            x0 = -1;
        }
    }
    int mouseDragged()
    {
        if ( x0 >= 0 ){
            int d = mouseX - x0;
            if ( d > delta ){
                int dx = (int)(d/delta);
                x += dx*delta;
                x0 = mouseX;
                return dx;
            }
            else if ( d < -delta ){
                int dx = (int)(-d/delta);
                if ( x - dx*delta > 0 ){
                    x -= dx*delta;
                    x0 = mouseX;
                    return -dx;
                }
            }
        }
        return 0;
    }
};



class PhotoPanel
{
    int x,y,w,h,yshift,ymargin,lastx;
    PImage pattern;
    PhotoPanel(int x_, int y_, int width, int height)
    {
        x = x_;
        y = y_;
        w = width;
        h = height;
        yshift = 0;
    }
    void draw(var colors, var patterns, var mode, var symm)
    {
        if ( mode == 1 ){
            pattern = PhotorealPattern(colors,patterns,symm,BINW);
        }
        else if ( mode == 2 ){
            pattern = QuickPattern(colors,patterns,symm,BINW);
        }
        PGraphics cc = createGraphics(w,h);
        float zoom = cc.width / pattern.width;
        cc.translate(0,-yshift);
        cc.scale(zoom,zoom);
        int rep = (int)(h/w+1);
        for(int i=0;i<rep;i++){
            cc.image(pattern,0,pattern.height*i);
        }
        ymargin = pattern.height*rep - h / w * pattern.width;
        image(cc,x,y);
    }
    int mousePressed()
    {
        lastx = mouseX;
    }
    int mouseDragged(var patterns, int binw)
    {
        if ( ( x < mouseX ) && ( mouseX < x+w ) &&
            (y < mouseY ) && (mouseY < y+h ) ){
            int delta = (mouseY - pmouseY);
            yshift -= delta;
            if ( yshift <= 0 ) yshift = 0;
            if ( yshift >= ymargin) yshift = ymargin;
            if ( binw ){
                delta = (int)((mouseX - lastx) / binw);
                if ( delta ){
                    lastx = mouseX;
                }
                while ( delta > 0 ){
                    var p = patterns.pop();
                    patterns.unshift(p);
                    delta -= 1;
                }
                while ( delta < 0 ){
                    var p = patterns.shift();
                    patterns.push(p);
                    delta += 1;
                }
            }
            return 1;
        }
        return 0;
    }
};



class PreviewPanel
{
    int x,y,w,h,shift;
    Array pattern;
    PreviewPanel(int x_, int y_, int width, int height)
    {
        x = x_;
        y = y_;
        w = width;
        h = height;
        shift = 2;
        pattern = new Array(4);
    }
    void draw(var colors, var patterns, var mode)
    {
        if ( mode == 1 ){
            for(int i=0;i<4;i++){
                pattern[i] = BasicPattern(colors,patterns,1<<i);
            }
        }
        else if ( mode == 2 ){
            for(int i=0;i<4;i++){
                pattern[i] = QuickPattern(colors,patterns,patterns,1<<i);
            }
        }
        PGraphics canvas = createGraphics(w,h);
        int iw = (int)(w / pattern[shift].width+1);
        int ih = (int)(h / pattern[shift].width+1);
        for(int i=0;i<iw;i++){
            for(int j=0;j<ih;j++){
                canvas.image(pattern[shift],pattern[shift].width*i,pattern[shift].width*j);
            }
        }
        image(canvas,x,y);
    }
    int mousePressed()
    {
        if ( ( x <= mouseX ) && ( mouseX < x+w ) &&
         ( y <= mouseY ) && ( mouseY < y+h ) ){
            shift ++;
            if ( shift == 4 ){
                shift = 0;
            }
            return 1;
        }
        return 0;
    }

};

class StripeChooser
{
    int x,y,w,h;
    int oy,ox,lastx;
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
        if ( ( 0 <= ix ) && ( ix < patterns.length() ) &&
             (0 <= iy ) && (iy < colors.length() )){
            patterns[(int)ix] = (int)iy;
            ox = (int)ix;
            oy = (int)iy;
            lastx = ox;
            return 1;
        }
        return 0;
    }
    int mouseDragged(var colors, var patterns)
    {
        var binwidth = w / patterns.length();
        var binheight = h / colors.length();
        int ix = (int)(( mouseX - x ) / binwidth);
        int iy = (int)(( mouseY - y ) / binheight);
        if ( ( 0 <= ix ) && ( ix < patterns.length() ) ){
            if ( ox < ix ){
                if ( ix < lastx ){
                    int next = (lastx + 1) % patterns.length;
                    for(int i=ix+1;i <=lastx; i++){
                        patterns[i] = patterns[next];
                    }
                }
                else{
                    for(int i=lastx;i<=ix;i++){
                        patterns[i] = oy;
                    }
                }
            }
            else{
                if ( ix > lastx ){
                    int next = (lastx - 1 + patterns.length) % patterns.length;
                    for(int i=lastx;i <ix; i++){
                        patterns[i] = patterns[next];
                    }
                }
                else{
                    for(int i=ix;i<=lastx;i++){
                        patterns[i] = oy;
                    }
                }
            }
            lastx = ix;
            return 1;
        }
        return 0;
    }
};


class ColorChooser
{
    int x,y,w,h;
    int selected;
    ColorChooser(int x_,int y_,int w_,int h_)
    {
        x = x_;
        y = y_;
        w = w_;
        h = h_;
        selected = 0;
    }
    void draw(var colors)
    {
        //all colors
        var h1 = h / colors.length;
        textSize(h1*0.28);
        var x0 = x + h1*1.1;
        for(int j=0;j<colors.length; j++){
            //selected color
            var col = colors[j];
            color c;
            if ( j == selected ){
                stroke(0,100,100);
                strokeWeight(3);
            }
            else{
                stroke(0,0,0);
                strokeWeight(1);
            }
            c = color(col[0],col[1],col[2]);
            fill(c);
            var y0 = y + h1*j;
            ellipse(x+h1/2,y0+h1*0.5,h1*0.9,h1*0.9);
            fill(0);
            textAlign(LEFT);
            text("H",x0,y0+h1*0.3);
            text("S",x0,y0+h1*0.6);
            text("B",x0,y0+h1*0.9);
            textAlign(RIGHT);
            text((int)(col[0]*3.6),x0+h1,y0+h1*0.3);
            text((int)col[1],x0+h1,y0+h1*0.6);
            text((int)col[2],x0+h1,y0+h1*0.9);
        }
        //selected color
        var col = colors[selected];
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
        var barheight = h1;
        var margin = h1*1.5 + barheight;
        var x0 = x + margin;
        var barwidth  = w - margin;
        pushMatrix();
        translate(x0,y);
        scale(barwidth/100,barheight);
        fill(255);
        image(hue,0,0);
        image(sat,0,1);
        image(bri,0,2);
        popMatrix();
        fill(100,0,100,100);
        stroke(0);
        strokeWeight(1);
        for(int i=0;i<3;i++){
            beginShape();
            vertex(col[i]*barwidth/100+x0,y+barheight*(i+0.5));
            vertex(col[i]*barwidth/100+x0-barheight/3,y+barheight*i);
            vertex(col[i]*barwidth/100+x0+barheight/3,y+barheight*i);
            endShape(CLOSE);
        }

        textSize(barheight*0.7);
        fill(100,0,0,100);
        textAlign(RIGHT);
        text((int)(col[0]*3.6),x0+barwidth+1,y+barheight*0.8+1);
        text((int)col[1],x0+barwidth+1,y+barheight*1.8+1);
        text((int)col[2],x0+barwidth+1,y+barheight*2.8+1);
        textAlign(LEFT);
        text("H 色",x0+1,y+1+barheight*0.8);
        text("S 彩",x0+1,y+1+barheight*1.8);
        text("B 明",x0+1,y+1+barheight*2.8);
        fill(100,0,100,100);
        textAlign(RIGHT);
        text((int)(col[0]*3.6),x0+barwidth,y+barheight*0.8);
        text((int)col[1],x0+barwidth,y+barheight*1.8);
        text((int)col[2],x0+barwidth,y+barheight*2.8);
        textAlign(LEFT);
        text("H 色",x0,y+barheight*0.8);
        text("S 彩",x0,y+barheight*1.8);
        text("B 明",x0,y+barheight*2.8);
    }
    int mousePressed(var colors, int select)
    {
        var h1 = h / colors.length;
        if (( x < mouseX) && ( mouseX <= x+h1 ) ){
            selected = (int)( (mouseY-y) / h1 );
            return 8;
        }
        var barheight = h1;
        var margin = h1*1.5 + barheight;
        var col = colors[selected];
        var x0 = x + margin;
        var barwidth  = w - margin;
        if (( x0 < mouseX) && ( mouseX <= x0+barwidth ) ){
            if ( (y < mouseY) && (mouseY <= y+barheight)  && ( select & 1 )){
                int hue = (mouseX-x0)*100/barwidth;
                col[0] = hue;
                return 1;
            }
            else if ( (y+barheight < mouseY) && (mouseY <= y+barheight*2) && ( select & 2 )  ){
                int sat = (mouseX-x0)*100/barwidth;
                col[1] = sat;
                return 2;
            }
            else if ( (y+barheight*2 < mouseY) && (mouseY <= y+barheight*3) && ( select & 4 )  ){
                int bri = (mouseX-x0)*100/barwidth;
                col[2] = bri;
                return 4;
            }
        }
        return 0;
    }
        
};


colors = [];
colors[0] = [0,98,80];
colors[1] = [56/3.6,98,80];
colors[2] = [33,98,20];
colors[3] = [66,98,40];
colors[4] = [0,0,80];
colors[5] = [0,0,5];
 
var patterns = [4,4,4,4,0,0,5,0,0,0,0,2,2,2,2,2,2,4,4,5,1,1,5,5,5,5,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
var winx = 800;
var winy = 600;
var photow = BINW*patterns.length();
var photoh = 300;
var margin = 10;
var previeww = winx - margin - photow;
var previewh = photoh;
var cntlheight = winy - photoh - 1;
var barheight = cntlheight / colors.length();
PhotoPanel photopanel = new PhotoPanel(0,0,photow,photoh);
Bar bar = new Bar(photow,0,margin,winy,BINW);
PreviewPanel previewpanel = new PreviewPanel(photow+margin,0,previeww,previewh);
StripeChooser sc = new StripeChooser(0,photoh,photow,cntlheight);
ColorChooser cc = new ColorChooser(photow+margin,photoh,previeww-margin,cntlheight);
CheckBox cb1 = new CheckBox(photow+previewh/2, photoh+previewh/2+margin, previewh/18., 0, "Asymmetric");
//CheckBox cb2 = new CheckBox(photow+previewh/2, photoh+previewh/2+previewh/9, previewh/18., 0, "Narrow bin");

void setup() {
    noStroke(0);
    fill(0);
    textSize(barheight*0.6);
    textAlign(CENTER);
    frameRate(24);
    colorMode(HSB, 100);
    size(800,600);
    noLoop();
}



//basic
PImage BasicPattern(var colors, var patterns, int sup)
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

//photorealistic
PImage PhotorealPattern(var colors, var patterns, var symm, int sup)
{
    PImage pattern = createImage(patterns.length()*sup, symm.length()*sup,ARGB);
    int L = 0;
    for(int i=0; i<symm.length()*sup;i++){
        for(int j=0; j<patterns.length()*sup;j++){
            i2 = i >> 1;
            j2 = j >> 1;
            int k = (i2+j2) % 4;
            int  p;
            float ratio;
            if ( k < 2 ){
                p = symm[(int)(i/sup)];
                ratio = 100 - random(20);
                if ( i & 1 ){
                    ratio -=20;
                }
            }
            else{
                p = patterns[(int)(j/sup)];
                ratio = 100 + random(20);
                if ( j & 1 ){
                    ratio -=20;
                }
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


//quick
PGraphics QuickPattern(var colors, var patterns, var symm, int sup)
{
    PGraphics pattern = createGraphics(patterns.length()*sup, symm.length()*sup);
    pattern.noStroke();
    pattern.colorMode(HSB,100);
    for(int j=0; j<patterns.length();j++){
        int p = patterns[j];
        var c = colors[p];
        pattern.fill(c[0],c[1],c[2],100);
        pattern.rect(j*sup,0,sup,pattern.height);
    }
    for(int i=0; i<symm.length();i++){
        int p = symm[i];
        var c = colors[p];
        pattern.fill(c[0],c[1],c[2],60);
        pattern.rect(0,i*sup,pattern.width,sup);
    }
    return pattern;
}



int pressedBar = 0;
int dragMode = 0;
int colorChanged = 1;
int viewChanged = 1;
int drawMode = 1; //2: quick, but need refresh; 1: photorealistic

void mousePressed()
{
    colorChanged = 0;
    viewChanged = 0;
    dragMode = 0;
    if ( sc.mousePressed(colors, patterns) ){
        colorChanged = 1;
        dragMode = 3;
    }
    pressedBar = cc.mousePressed(colors,7);
    if ( pressedBar ){
        if ( pressedBar == 8 ){
            //ellipse selected; no drag, no redraw
            colorChanged = 2;
        }
        else{
            colorChanged = 3;
            dragMode = 4;
        }
    }
    bar.mousePressed();
    photopanel.mousePressed();
    if ( previewpanel.mousePressed() ){
        viewChanged = 1;
    }
    if ( cb1.mousePressed() ){
        colorChanged = 4;
    }
    /*if ( cb2.mousePressed() ){
        colorChanged = 5;
        if (cb2.checked ){
            BINW = 4;
        }
        else{
            BINW = 8;
        }
    }*/
    //println(["mp",viewChanged,colorChanged]);
    if ( colorChanged ){
        drawMode = 2;
    }
    else if ( viewChanged ){
        drawMode = 0;
    }
    loop();
}


void mouseDragged()
{
    if ( dragMode == 4 ){
        if ( cc.mousePressed(colors,pressedBar) ){
            colorChanged = 1;
        }
    }
    else if ( dragMode == 3 ){
        if ( sc.mouseDragged(colors, patterns) ){
            colorChanged = 1;
        }
    }
    else{
        int delta = bar.mouseDragged();
        if ( delta ){
            if ( delta < 0 ){
                patterns.length += delta;
            }
            if ( delta > 0 ){
                var c = patterns[patterns.length-1];
                for(int i=0; i<delta; i++){
                    patterns.push(c);
                }
            }
            if ( delta ){
                //left
                photopanel.w += BINW*delta;
                sc.w         += BINW*delta;
                //right
                previewpanel.w -= BINW*delta;
                previewpanel.x += BINW*delta;
                cc.w -= BINW*delta;
                cc.x += BINW*delta;
                cb1.x += BINW*delta;
                colorChanged = 1;
            }
        }
        int b = cb1.checked;
        if ( b ){
            b = BINW;
        }
        if ( photopanel.mouseDragged(patterns, b) ){
            viewChanged = 1;
            if ( b ){
                colorChanged = 1;
            }
        }
    }
    if ( colorChanged ){
        drawMode = 2;
    }
    else if ( viewChanged ){
        drawMode = 0;
    }
    loop();
}

void mouseReleased()
{
    if ( drawMode == 2 ){
        colorChanged = 1;
        drawMode = 1;
    }
    loop();
}



var symmetrize(var patterns)
{
    var symm = [];
    int left = 0;
    for(int i=0;i<patterns.length; i++){
        if ( patterns[i] != patterns[0] ){
            break;
        }
        left = i;
    }
    int right;
    for(int i=patterns.length-1; i>=0; i--){
        if ( patterns[i] != patterns[patterns.length-1] ){
            break;
        }
        right = i;
    }
    for(int i=0;i<patterns.length; i++){
        symm[i] = patterns[i];
    }
    for(int i=right-1;left<i;i--){
        symm.push(patterns[i]);
    }
    return symm;
}




void draw() {
    if ( colorChanged == 1 ){
        //after photorealistic rendering, loop stops.
        noLoop();
    }
    if ( colorChanged || viewChanged ){
        if(colorChanged)background(100,0,100);
        fill(255);
        int asymm = cb1.checked;
        var symm;
        if ( asymm ){
            symm = patterns;
        }
        else{
            symm = symmetrize(patterns);
        }
        //var now = (new Date()).getTime();
        photopanel.draw(colors,patterns,drawMode,symm);
        //var now2 = (new Date()).getTime();
        //println([1,now2-now]);
        //now = now2;
        previewpanel.draw(colors, symm,drawMode);
        //var now2 = (new Date()).getTime();
        //println([2,now2-now]);
        //now = now2;
        if ( colorChanged ){
            bar.draw();
            sc.draw(colors,patterns);
            cc.draw(colors);
            cb1.draw();
        }
        //var now2 = (new Date()).getTime();
        //println([3,now2-now]);
        //now = now2;
        //cb2.draw();
        colorChanged = 0;
        viewChanged = 0;
    }
}
