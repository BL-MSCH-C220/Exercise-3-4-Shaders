# Exercise 3.4—Shaders

Exercise for MSCH-C220

This is the last exercise for you to experiment with juicy features in our brick-breaker game. The exercise will focus on adding shaders to several elements and a face to the paddle.

The expectations for this exercise are that you will

 - [ ] Fork and clone this repository
 - [ ] Import the project into Godot
 - [ ] Add shaders to the main menu background, the fever bar, and the game backgound (when in fever mode)
 - [ ] Animate the game background (cycle through colors)
 - [ ] Add a face to the paddle that reacts to the ball
 - [ ] Add a WorldEnvironment to introduce blur and glow to the game elements
 - [ ] Edit the LICENSE and README.md
 - [ ] Commit and push your changes back to GitHub. Turn in the URL of your repository on Canvas.

## Instructions

Fork this repository. When that process has completed, make sure that the top of the repository reads [your username]/Exercise-3-4-Shaders. *Edit the LICENSE and replace BL-MSCH-C220 with your full name.* Commit your changes.

Press the green "Code" button and select "Open in GitHub Desktop". Allow the browser to open (or install) GitHub Desktop. Once GitHub Desktop has loaded, you should see a window labeled "Clone a Repository" asking you for a Local Path on your computer where the project should be copied. Choose a location; make sure the Local Path ends with "Exercise-3-4-Shaders" and then press the "Clone" button. GitHub Desktop will now download a copy of the repository to the location you indicated.

Open Godot. In the Project Manager, tap the "Import" button. Tap "Browse" and navigate to the repository folder. Select the project.godot file and tap "Open".

If you run the project, you will see a main menu followed by a simple brick-breaker game. We will now have an opportunity to start making it "juicier".

---

## Adding Shaders

Our first step will be to add some shaders to our project. To make the main menu a bit more visually interesting, we are going to add a shader to the background. Open `res://UI/Main_Menu.tscn`. Select the Background node. In the Inspector panel, select CanvasItem->Material->Material: New Shader Material. Then Edit the new Shader Material and add a New Shader. Edit that Shader and paste the following into the shader editor that appears at the bottom of the window:
```
// Water shader

shader_type canvas_item;
uniform int OCTAVE = 6;
uniform float mulscale = 5.0;
uniform float height = 0.6;
uniform float tide = 0.1;
uniform float foamthickness = 0.1;
uniform float timescale = 1.0;
uniform float waterdeep = 0.3;
uniform vec4 WATER_COL : hint_color =  vec4(0.1, 0.44, 0.76, 1.0);
uniform vec4 WATER2_COL : hint_color =  vec4(0.09, 0.39, 0.67, 1.0);
uniform vec4 FOAM_COL : hint_color = vec4(0.13, 0.55, 0.9, 1.0);


float rand(vec2 input){
	return fract(sin(dot(input,vec2(23.53,44.0)))*42350.45);
}

float perlin(vec2 input){
	vec2 i = floor(input);
	vec2 j = fract(input);
	vec2 coord = smoothstep(0.,1.,j);
	
	float a = rand(i);
	float b = rand(i+vec2(1.0,0.0));
	float c = rand(i+vec2(0.0,1.0));
	float d = rand(i+vec2(1.0,1.0));

	return mix(mix(a,b,coord.x),mix(c,d,coord.x),coord.y);
}

float fbm(vec2 input){
	float value = 0.0;
	float scale = 0.5;
	
	for(int i = 0; i < OCTAVE; i++){
		value += perlin(input)*scale;
		input*=2.0;
		scale*=0.5;
	}
	return value;
}

void fragment(){
	float newtime = TIME*timescale;
	float fbmval = fbm(vec2(UV.x*mulscale+0.2*sin(0.3*newtime)+0.15*newtime,-0.05*newtime+UV.y*mulscale+0.1*cos(0.68*newtime)));
	float fbmvalshadow = fbm(vec2(UV.x*mulscale+0.2*sin(-0.6*newtime + 25.0 * UV.y)+0.15*newtime+3.0,-0.05*newtime+UV.y*mulscale+0.13*cos(-0.68*newtime))-7.0+0.1*sin(0.43*newtime));
	float myheight = height+tide*sin(newtime+5.0*UV.x-8.0*UV.y);
	float shadowheight = height+tide*1.3*cos(newtime+2.0*UV.x-2.0*UV.y);
	float withinFoam = step(myheight, fbmval)*step(fbmval, myheight + foamthickness);
	float shadow = (1.0-withinFoam)*step(shadowheight, fbmvalshadow)*step(fbmvalshadow, shadowheight + foamthickness * 0.7);
	COLOR = withinFoam*FOAM_COL + shadow*WATER2_COL + ((1.0-withinFoam)*(1.0-shadow))*WATER_COL;
	//COLOR = vec4(1.0,1.0,1.0,fbmval);
}
```

When you go back to the 2D view, you should now see the background appear as animating ripples of water.

Next, we will add some shaders when we go into fever mode.

When fever mode starts, we want to add a fire shader to the fever bar. In `res://UI/HUD.tscn`, select the Fever node.  In the Inspector panel, select CanvasItem->Material->Material: New Shader Material. Then Edit the new Shader Material and add a New Shader. Edit that Shader and paste the following into the shader editor that appears at the bottom of the window:
```
// Fire shader

shader_type canvas_item;

uniform vec2 fireMovement = vec2(-0.01, -0.5);
uniform vec2 distortionMovement = vec2(-0.01, -0.3);
uniform float normalStrength = 40.0;
uniform float distortionStrength=0.1;


/** NOISE **/
float rand(vec2 co) {
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 hash( vec2 p ) {
	p = vec2( dot(p,vec2(127.1,311.7)),
			dot(p,vec2(269.5,183.3)) );

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p ) {
	float K1 = 0.366025404; // (sqrt(3)-1)/2;
	float K2 = 0.211324865; // (3-sqrt(3))/6;

	vec2 i = floor( p + (p.x+p.y)*K1 );

	vec2 a = p - i + (i.x+i.y)*K2;
	vec2 o = step(a.yx,a.xy);    
	vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;

	vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );

	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));

	return dot( n, vec3(70.0) );
}

float fbm ( in vec2 p ) {
	float f = 0.0;
	mat2 m = mat2(vec2(1.6,  1.2), vec2(-1.2,  1.6 ));
	f  = 0.5000*noise(p); p = m*p;
	f += 0.2500*noise(p); p = m*p;
	f += 0.1250*noise(p); p = m*p;
	f += 0.0625*noise(p); p = m*p;
	f = 0.5 + 0.5 * f;
	return f;
}

/** DISTORTION **/
vec3 bumpMap(vec2 uv) { 
	vec2 iResolution = vec2(1024,600);
	vec2 s = 1. / iResolution.xy;
	float p =  fbm(uv);
	float h1 = fbm(uv + s * vec2(1., 0));
	float v1 = fbm(uv + s * vec2(0, 1.));
		 
	vec2 xy = (p - vec2(h1, v1)) * normalStrength;
	return vec3(xy + .5, 1.);
}

/** MAIN **/
void fragment() {
	float timeScale = TIME * 1.0;
	vec2 iResolution = vec2(1024,600);
	vec2 uv = FRAGCOORD.xy/iResolution.xy;

	vec3 normal = bumpMap(uv * vec2(1.0, 0.3) + distortionMovement * timeScale);
	
	vec2 displacement = clamp((normal.xy - .5) * distortionStrength, -1., 1.);
	uv += displacement; 
	
	vec2 uvT = (uv * vec2(1.0, 0.5)) + timeScale * fireMovement;
	float n = pow(fbm(8.0 * uvT), 1.0);    
	
	float gradient = pow(1.0 - uv.y, 2.0) * 5.;
	float finalNoise = n * gradient;
	
	vec3 color = finalNoise * vec3(2.*n, 2.*n*n*n, n*n*n*n);
	COLOR = vec4(color, 1.);
}
```

Select the Fever node again, and set CanvasItem->Material->Use Parent Material: on

Then, edit `res://Effects/Fever.gd`. Change `start_fever` to turn on the fire:
```
func start_fever():
	fever()
	$Timer.start()
	var fever_indicator = get_node_or_null("/root/Game/UI/HUD/Fever")
	if fever_indicator != null:
		fever_indicator.use_parent_material = false
```

Then turn it off when we are no longer feverish (in `_on_Timer_timeout`):
```
func _on_Timer_timeout():
	if Global.feverish:
		fever()
		$Timer.start()
	else:
		var fever_indicator = get_node_or_null("/root/Game/UI/HUD/Fever")
		if fever_indicator != null:
			fever_indicator.use_parent_material = true
```

When the game is not in fever mode, we would like to make the fever bar a little more colorful.

Edit `res://UI/HUD.gd`. Replace the `update_fever` function with the following:
```
func update_fever():
	$Fever.value = Global.fever
	var styleBox = $Fever.get("custom_styles/fg")
	styleBox.bg_color.h = fever_h
	styleBox.bg_color.s = (Global.fever / 100.0) * fever_s
	styleBox.bg_color.v = (fever_v/2) + ((Global.fever / 100.0) * (fever_v/2)) 
```




In `res://Game.tscn`, select the Background node. In the Inspector panel, select CanvasItem->Material->Material: New Shader Material. Then Edit the new Shader Material and add a New Shader. Edit that Shader and paste the following into the shader editor that appears at the bottom of the window:
```
// Fireworks shader
// Based on shadertoy shader by Martijn Steinrucken aka BigWings - 2015 
// (https://www.shadertoy.com/view/lscGRl)

shader_type canvas_item;

uniform float PI = 3.141592653589793238;
uniform float TWOPI = 6.283185307179586 ;
uniform float NUM_EXPLOSIONS = 8.0;
uniform float NUM_PARTICLES = 70.0;

// Noise functions by Dave Hoskins

uniform vec3 MOD3 = vec3(0.1031,0.11369,0.13787);

vec3 hash31(float p) {
	vec3 p3 = fract(vec3(p) * MOD3);
	p3 += dot(p3, p3.yzx + 19.19);
	return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

float hash12(vec2 p) // attention changement vec2 p en vec3
{
	vec3 p3  = fract(vec3(p.xy, 0.0) * MOD3);
	p3 += dot(p3, p3.yzx + 19.19);
	return fract((p3.x + p3.y) * p3.z);
}

float circ(vec2 uv, vec2 pos, float size) {
	uv -= pos;
	size *= size;
	return smoothstep(size*1.1, size, dot(uv, uv));
}

float lighter(vec2 uv, vec2 pos, float size) {
	uv -= pos;
	size *= size;
	return size/dot(uv, uv);
}

vec3 explosion(vec2 uv, vec2 p, float seed, float t) {
	vec3 col = vec3(0.);
	vec3 en = hash31(seed);
	vec3 baseCol = en;
	for(float i=0.; i<NUM_PARTICLES; i++) {
		vec3 n = hash31(i)-.5;
		vec2 startP = p-vec2(0., t*t*.1);        
		vec2 endP = startP+normalize(n.xy)*n.z;
		float pt = 1.-pow(t-1., 2.);
		vec2 pos = mix(p, endP, pt);    
		float size = mix(.01, .005, smoothstep(0., .1, pt));
		size *= smoothstep(1., .1, pt);
		float sparkle = (sin((pt+n.z)*100.)*.5+.5);
		sparkle = pow(sparkle, pow(en.x, 3.)*50.)*mix(0.01, .01, en.y*n.y);
		float B = smoothstep(en.x-en.z, en.x+en.z, t)*smoothstep(en.y+en.z, en.y-en.z, t);
		size += sparkle*B;
		col += baseCol*lighter(uv, pos, size);
	}
	return col;
}


void fragment() {
	vec2 iResolution = vec2(1024,600);
	vec2 uv = FRAGCOORD.xy / iResolution.xy;
	uv.x -= .5;
	uv.x *= iResolution.x/iResolution.y;

	float n = hash12(uv+10.0);
	float t = TIME*.5;

	vec3 c = vec3(0.);

	for(float i=0.; i<NUM_EXPLOSIONS; i++) {
		float et = t+i*1234.45235;
		float id = floor(et);
		et -= id;
		
		vec2 p = hash31(id).xy;
		p.x -= .5;
		p.x *= 1.6;
		c += explosion(uv, p, id, et);
	}

	float alpha = 1.0;
	COLOR = vec4(c, alpha);
}
```

Select the Background node again. In the Inspector, set CanvasItem->Material->Use Parent Material: on

Once again, edit `res://Effects/Fever.gd`. Change `start_fever` to start the fireworks:
```
func start_fever():
	fever()
	$Timer.start()
	var fever_indicator = get_node_or_null("/root/Game/UI/HUD/Fever")
	if fever_indicator != null:
		fever_indicator.use_parent_material = false
	var background = get_node_or_null("/root/Game/Background")
	if background != null:
		background.use_parent_material = false
```

Then turn them off when we are no longer feverish (in `_on_Timer_timeout`):
```
func _on_Timer_timeout():
	if Global.feverish:
		fever()
		$Timer.start()
	else:
		var fever_indicator = get_node_or_null("/root/Game/UI/HUD/Fever")
		if fever_indicator != null:
			fever_indicator.use_parent_material = true
		var background = get_node_or_null("/root/Game/Background")
		if background != null:
			background.use_parent_material = true
```

*The fireworks shader requires a lot of computing resources. If that is a problem for your computer, comment out the line that turns it on (`#background.use_parent_material = false`)*

## Rotating Background Colors

When we aren't in fever mode, we want the game background color to subltly animate. In `res://Game.tscn`, add a Tween node as a child of Background. Then attach the following script to the Background node (save it as `res://Effects/Background.gd`):

```
extends ColorRect

var c = 0
var tween

var colors = [
	Color8(0,0,0,255)     #black
	,Color8(33,37,41,255)   #gray 9
	,Color8(52,58,64,255)   #gray 8
	,Color8(73,80,87,255)   #gray 7
	,Color8(52,58,64,255)   #gray 8
	,Color8(33,37,41,255)   #gray 9
]

func _ready():
	update_color()

func update_color():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "color", colors[c], 2.0)
	tween.tween_completed(_tween_completed)

func _tween_completed():
	c = wrapi(c+1, 0, colors.size())
	update_color()
```

## Drawing a face

In your web browser, go to `https://www.piskelapp.com`. This is where we will create the images for the paddle's face.

The first image is the white part of the eye. Create a new sprite and resize the drawing area (unchecking maintain aspect ratio) to 24 x 39. Then draw and fill a white oval that takes up the remaining area. Decorate it as you see fit, then export it as a PNG, "Spritesheet file export". Rename the resulting file as eye.png and copy it into `res://Assets`.

Next, still in Piskel, create a new image. Resize it to 15 x 15 and draw and fill a black circle. Export it as a PNG and rename it pupil. Copy it into the Assets folder in your project.

Finally, create a new sprite, and resize it to 50 x 25. Draw and fill a black semi-circle, export it as a PNG, rename it mouth.png, and copy it into the Assets folder.

Back in Godot, open `res://Paddle/Paddle.tscn`. Add a Sprite as a child of the Paddle and name it Eye1. Set its texture as `res://Assets/eye.png`. Then *as a child of Eye1,* add a Node2D and rename it Pupil. Finally, add a Sprite as a child of the Pupil node and set its texture as `res://Assets/pupil.png`. Eye1 should be positioned at 23, -7; the Pupil node and its child Sprite can both remain at 0,0.

Follow that same process for Eye2 Eye2 should be positioned at 73, -7; the Pupil node and its child Sprite can both remain at 0,0.

As a child of Paddle, add a Sprite node and name it Mouth. Its texture should be set to `res://Assets/Mouth.png`. Position the mouth at 49, 26.

To animate the face, edit `res://Paddle/Paddle.gd`. The `_physics_process` callback should be as follows:
```
func _physics_process(_delta):
	target.x = clamp(target.x, 0, Global.VP.x - 2*width)
	position = target
	var ball_container = get_node_or_null("/root/Game/Ball_Container")
	if ball_container != null and ball_container.get_child_count() > 0:
		var ball = ball_container.get_child(0)
		$Eye1/Pupil/Sprite.position.x = 7
		$Eye2/Pupil/Sprite.position.x = 7
		$Eye1/Pupil.look_at(ball.position)
		$Eye2/Pupil.look_at(ball.position)
		var d = ((($Mouth.global_position.y - ball.global_position.y)/Global.VP.y)-0.2)*2
		d = clamp(d, -1, 1)
		$Mouth.scale.y = d
	else:
		$Eye1/Pupil/Sprite.position.x = 0
		$Eye2/Pupil/Sprite.position.x = 0
		$Mouth.scale.y = 1
```

## WorldEnvironment

In `Game.tscn`, right-click on the Wall_Container node and Change Type. Select CanvasLayer (we don't want the walls to bleed into the rest of the game once we add the WorldEnvironment).

Now, right-click on the Game node and Add Child Node. Select WorldEnvironment. Tap on the WorldEnvironment node and in the Inspector, select Envrionment->New Environment. Then Edit that new Enviornment:
 * Background->Mode: Canvas
 * DOF Near Blur->Enabled: On
 * DOF Near Blur->Distance: 1.3
 * Glow->Enabled: On
 * Glow->Bloom: 0.03
 * Glow->Blend Mode: Additive
 * Glow->Bicubic Upscale: ON

*If the Background Mode is set to anything other then Canvas, the results won't be visible. Make sure you don't miss that step.*

---

Test the game and make sure it is working correctly. You should be able to see the combination of all the effects we have added (including fever mode when you click the mouse button).

Quit Godot. In GitHub desktop, you should now see the updated files listed in the left panel. In the bottom of that panel, type a Summary message (something like "Completes the exercise") and press the "Commit to master" button. On the right side of the top, black panel, you should see a button labeled "Push origin". Press that now.

If you return to and refresh your GitHub repository page, you should now see your updated files with the time when they were changed.

Now edit the README.md file. When you have finished editing, commit your changes, and then turn in the URL of the main repository page (https://github.com/[username]/Exercise-3-4-Shaders) on Canvas.

The final state of the file should be as follows (replacing my information with yours):
```
# Exercise 3.4—Shaders

Exercise for MSCH-C220

The final step adding "juicy" features to a simple brick-breaker game.

## To play

Move the paddle using the mouse. Release the ball (and trigger fever mode) using the left mouse button. Assist the ball in breaking all the bricks before you run out of time.

## Implementation

Created using [Godot 4.1.1](https://godotengine.org/download)

Face sprites created by the author at Piskel.com

## References
 * [Juice it or lose it — a talk by Martin Jonasson & Petri Purho](https://www.youtube.com/watch?v=Fy0aCDmgnxg)
 * [Puzzle Pack 2, provided by kenney.nl](https://kenney.nl/assets/puzzle-pack-2)
 * [Background Elements Redux, provided by kenney.nl](https://kenney.nl/assets/background-elements-redux)
 * [Open Color open source color scheme](https://yeun.github.io/open-color/)
 * [League Gothic Typeface](https://www.theleagueofmoveabletype.com/league-gothic)
 * [Orbitron Typeface](https://www.theleagueofmoveabletype.com/orbitron)
 * Shaders:
	 * [Fire Effect by Tsar333](https://godotshaders.com/shader/fire-effect/)
	 * [Fireworks by Tsar333](https://godotshaders.com/shader/fireworks/)
	 * [2D Procedural Water by flytrap](https://godotshaders.com/shader/perlin-procedural-water/)

## Future Development

Power-ups, etc.

## Created by 

Jason Francis
```