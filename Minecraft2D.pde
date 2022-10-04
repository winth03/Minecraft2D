Block[][] world = new Block[20][50];
Block[][] backWorld = new Block[20][50];
color[] blocks = new color[] { #91bd59, #714f36, #6c6c6c, #c6955c, #47371f, #1a330e };
String[] blockNames = { "Grass", "Dirt", "Stone", "Plank", "Wood", "Leaves" };
Player player;
PVector startPos, breaking;
float size = 75, speed = 5, treeChance = 0.3;
Boolean[] keys = {false, false, false, false};
Boolean back = false, hold = false;
int input, index = 0, startHold, breakTime = 500;

void setup() {
    size(1000, 800);
    startPos = new PVector((-world[0].length*size/2)/2, height/4);
    player = new Player();

    // Generate ground
    for (int x = 0; x < world[0].length; x++) {
        for (int y = world.length/2; y < world.length; y++) {
            world[y][x] = new Block(y != world.length/2 ? (y > world.length/2+3 ? (y != world.length-1 ? blocks[2] : #212121) : blocks[1]) : blocks[0]);
        }
    }
    // Generate background
    for (int x = 0; x < world[0].length; x++) {
        for (int y = world.length/2; y < world.length; y++) {
            backWorld[y][x] = new Block(y != world.length/2 ? (y > world.length/2+3 ? (y != world.length-1 ? blocks[2] : #212121) : blocks[1]) : blocks[0], true);
        }
    }

    // Generate trees
    for (int x = 4; x < world[0].length-5; x++) {
        if (random(1) < treeChance) {
            world[world.length/2-1][x] = new Block(blocks[4], true);
            world[world.length/2-2][x] = new Block(blocks[4], true);
            world[world.length/2-3][x] = new Block(blocks[5]);
            world[world.length/2-3][x-1] = new Block(blocks[5]);
            world[world.length/2-3][x+1] = new Block(blocks[5]);
            world[world.length/2-4][x] = new Block(blocks[5]);

            x += 4;
        }
    }
}

void draw() {
    background(#78A7FF);
    int mouseGridX = floor((mouseX - startPos.x) / size);
    int mouseGridY = floor((mouseY - startPos.y) / size);

    // Respawn
    if (startPos.y <= -2 * height) {
        startPos = new PVector(-world[0].length*size/2, height/4);
    }

    // Calculate inputs
    if (keys[0]) { // a key
        input += 1;
    }
    if (keys[1]) { // d key
        input -= 1;
    }
    // Move
    startPos.x = constrain(startPos.x + input * speed, -world[0].length*size + width, 0);

    if (keys[2] && !player.jump && player.OnGround() && !player.HeadCollide()) {
        player.jump = true;
        player.velo = sqrt(2*9.8*size*1.5);
    }
    if (keys[3]) {
        back = !back;
        keys[3] = false;
    }
    
    // Destroy Block
    if (breaking != null && mouseGridX >= 0 && mouseGridX <= world[0].length-1 && mouseGridY >= 0 && mouseGridY < world.length-1) {
        if (mouseGridX != int(breaking.x) || mouseGridY != int(breaking.y)) {
            if (world[mouseGridY][mouseGridX] != null || backWorld[mouseGridY][mouseGridX] != null) breaking = new PVector(mouseGridX, mouseGridY);
            startHold = millis();
        }
        else if (world[mouseGridY][mouseGridX] == null && backWorld[mouseGridY][mouseGridX] == null) {
            startHold = millis();
        }
    }
    else startHold = millis();
    int holdTime = millis() - startHold;
    if (hold && holdTime >= breakTime) {
        if (world[int(breaking.y)][int(breaking.x)] == null || int(breaking.y) == world.length-1) {
            if (backWorld[int(breaking.y)][int(breaking.x)] != null || int(breaking.y) != world.length-1) {
                backWorld[int(breaking.y)][int(breaking.x)] = null;
                startHold = millis();
            }
        } else {
            world[int(breaking.y)][int(breaking.x)] = null;
            startHold = millis();
        }
    }

    // Render boundaries
    noStroke();
    fill(255, 75);
    if (startPos.x >= -width) {
        rect(startPos.x + width/2 - size/2, 0, 0.1*size, height);
    }
    if (startPos.x <= -world[0].length*size + 2*width) {
        rect(startPos.x + world[0].length*size - width/2 + 0.8*size/2, 0, 0.1*size, height);
    }

    // Render background Blocks
    for (int x = 0; x < world[0].length; x++) {
        float posX = startPos.x + x * size;
        if (posX + size < 0 || posX > width) continue;
        for (int y = 0; y < world.length; y++) {
            float posY = startPos.y + y * size;
            if (posY + size < 0 || posY > height || backWorld[y][x] == null) continue;
            backWorld[y][x].render(posX, posY);
        }
    }
    // Render Blocks
    for (int x = 0; x < world[0].length; x++) {
        float posX = startPos.x + x * size;
        if (posX + size < 0 || posX > width) continue;
        for (int y = 0; y < world.length; y++) {
            float posY = startPos.y + y * size;
            if (posY + size < 0 || posY > height || world[y][x] == null) continue;
            world[y][x].render(posX, posY);
        }
    }
    if (hold && holdTime <= breakTime && breaking != null) {
        float breakProgress = constrain(float(holdTime)/breakTime, 0, 1);
        float halfX = startPos.x + (breaking.x + 1) * size - size/2;
        float halfY = startPos.y + (breaking.y + 1) * size - size/2;
        noStroke();
        fill(0, 50);
        rect(halfX-(size/2)*breakProgress, halfY-(size/2)*breakProgress, size*breakProgress, size*breakProgress);
    }

    // Calculate Player Physics
    if (player.jump) player.Jump();
    else player.Fall();
    player.WallCollide();

    // Render Player
    player.render();

    // Render UI
    fill(255);
    textSize(36);
    textAlign(LEFT, TOP);
    text("Selected: " + blockNames[index] + " Back: %b".formatted(back), 25, 25); // Show selected block

    input = 0;
}

void setKey(char k, Boolean state) {
    switch(k) {
    case 'a':
        keys[0] = state;
        break;
    case 'd':
        keys[1] = state;
        break;
    case ' ':
        keys[2] = state;
        break;
    case 'e':
        keys[3] = state;
        break;
    }
}

void mousePressed() {
    int x = floor((mouseX - startPos.x) / size);
    int y = floor((mouseY - startPos.y) / size);
    // float dist = dist(width/2, player.y, mouseX, mouseY);

    if (x < 0 || x > world[0].length-1 || y < 0 || y > world.length-1) return;
    if (mouseButton == LEFT) { // Destroy block
        if (!hold) {
            if (world[y][x] != null || backWorld[y][x] != null) breaking = new PVector(x, y);
            hold = true;
            startHold = millis();
            return;
        }
    } else if (mouseButton == RIGHT) { // Place block
        if (back) {
            if (backWorld[y][x] != null) return;
            backWorld[y][x] = new Block(blocks[index], back);
        } else {
            if (world[y][x] != null || ((x == player.left || x == player.right) && (y == player.bottom || y == player.head))) return;
            world[y][x] = new Block(blocks[index], back);
        }
    }
}

void mouseReleased() {
    if (mouseButton == LEFT) {
        hold = false;
    }
}

void keyPressed() {
    setKey(key, true);
}

void keyReleased() {
    setKey(key, false);
}

void mouseWheel(MouseEvent event) {
    int e = event.getCount();
    //size = constrain(size+e*5, 50, 150);
    index += e;
    if (index < 0) index = blocks.length-1;
    else if (index > blocks.length-1) index = 0;
}
