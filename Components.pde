class Block {
    PVector pos;
    color col;
    float durability = 10;
    Boolean passThrough;

    Block(color col) {
        this.col = col;
        this.passThrough = false;
    }
    Block(color col, Boolean pass) {
        this.col = pass ? color(constrain(red(col) - 30, 0, 255), constrain(green(col) - 30, 0, 255), constrain(blue(col) - 30, 0, 255)) : col;
        this.passThrough = pass;
    }

    void render(float x, float y) {
        stroke(0);
        fill(this.col);
        rect(x, y, size, size);
        this.pos = new PVector(x, y);
    }
}

class Player {
    float velo = 0;
    Boolean jump = false;
    int startTime = 0, left, right, bottom, head;

    Player() {
    }

    void render() {
        stroke(0);
        fill(255, 0, 0);
        rect((width-size*0.8) / 2, height/2 - 2 * size, size * 0.8, 2 * size);
    }

    void Jump() {
        if (this.velo > 0 && !this.HeadCollide()) {
            float deltaTime = 0;
            if (this.startTime == 0) {
                startTime = millis();
            } else {
                deltaTime = (millis() - startTime);
                deltaTime /= 50;
                startTime = millis();
            }
            this.velo -= 9.8 * deltaTime;
            startPos.y += this.velo * deltaTime;
        } else {
            this.jump = false;
            this.velo = 0;
            this.startTime = 0;
        }
    }

    void Fall() {
        if (!this.OnGround()) {
            float deltaTime = 0;
            if (this.startTime == 0) {
                startTime = millis();
            } else {
                deltaTime = (millis() - startTime);
                deltaTime /= 50;
                startTime = millis();
            }
            this.velo += 9.8 * deltaTime;
            startPos.y -= this.velo * deltaTime;
        } else {
            this.velo = 0;
            this.startTime = 0;
        }
    }

    void WallCollide() {
        // Debug
        Boolean rightCollided = false, leftCollided = false;
        int x1 = floor(((width/2 + size*1.8/2) - startPos.x) / size); // Right
        int x2 = floor(((width/2 - size*1.8/2) - startPos.x) / size); // Left
        int y1 = floor((height/2 - size * 0.2 - startPos.y) / size);
        int y2 = floor((height/2 - size * 0.2 - startPos.y - size) / size);
        //stroke(0, 0, 255);
        //noFill();
        //rect(startPos.x + x1 * size, startPos.y + y1 * size, size, size);
        //rect(startPos.x + x2 * size, startPos.y + y1 * size, size, size);
        //rect(startPos.x + x1 * size, startPos.y + y2 * size, size, size);
        //rect(startPos.x + x2 * size, startPos.y + y2 * size, size, size);
        //fill(0, 0, 255);
        //textAlign(CENTER, CENTER);
        //text("(x1, y1)", startPos.x + x1 * size, startPos.y + y1 * size, size, size);
        //text("(x2, y1)", startPos.x + x2 * size, startPos.y + y1 * size, size, size);
        //text("(x1, y2)", startPos.x + x1 * size, startPos.y + y2 * size, size, size);
        //text("(x2, y2)", startPos.x + x2 * size, startPos.y + y2 * size, size, size);
        this.bottom = y1;
        this.head = y2;

        if (x1 >= 0 && x1 < world[0].length && y1 >= 0 && y1 < world.length) { // Right
            if (world[y1][x1] != null && (width/2 + size*0.8/2) >= world[y1][x1].pos.x && !world[y1][x1].passThrough) {
                startPos.x -= world[y1][x1].pos.x - width/2 - size*0.8/2;
                rightCollided = true;
            }
        }
        if (x1 >= 0 && x1 < world[0].length && y2 >= 0 && y2 < world.length && !rightCollided) {
            if (world[y2][x1] != null && (width/2 + size*0.8/2) >= world[y2][x1].pos.x && !world[y2][x1].passThrough) {
                startPos.x -= world[y2][x1].pos.x - width/2 - size*0.8/2;
            }
        }
        if (x2 >= 0 && x2 < world[0].length && y1 >= 0 && y1 < world.length) { // Left
            if (world[y1][x2] != null && (width/2 - size*0.8/2) <= world[y1][x2].pos.x+size && !world[y1][x2].passThrough) {
                startPos.x -= (world[y1][x2].pos.x + size) - width/2 + size*0.8/2;
                leftCollided = true;
            }
        }
        if (x2 >= 0 && x2 < world[0].length && y2 >= 0 && y2 < world.length && !leftCollided) {
            if (world[y2][x2] != null && (width/2 - size*0.8/2) <= world[y2][x2].pos.x+size  && !world[y2][x2].passThrough) {
                startPos.x -= (world[y2][x2].pos.x + size) - width/2 + size*0.8/2;
            }
        }
    }
    
    Boolean HeadCollide() {
        // Debug
        int x1 = floor(((width/2 + size*0.6/2) - startPos.x) / size);
        int x2 = floor(((width/2 - size*0.6/2) - startPos.x) / size);
        int y = floor((height/2 - size * 2.1 - startPos.y) / size);
        //stroke(255, 0, 0);
        //noFill();
        //rect(startPos.x + x1 * size, startPos.y + y * size, size, size);
        //rect(startPos.x + x2 * size, startPos.y + y * size, size, size);

        if (x1 >= 0 && x1 < world[0].length && y >= 0 && y < world.length) {
            if (world[y][x1] != null && !world[y][x1].passThrough) {
                return true;
            }
        }
        if (x2 >= 0 && x2 < world[0].length && y >= 0 && y < world.length) {
            if (world[y][x2] != null && !world[y][x2].passThrough) {
                return true;
            }
        }
        return false;
    }

    Boolean OnGround() {
        // Debug
        int x1 = floor(((width/2 + size*0.6/2) - startPos.x) / size);
        int x2 = floor(((width/2 - size*0.6/2) - startPos.x) / size);
        int y = floor((height/2 + size * 0.1 - startPos.y) / size);
        //stroke(255, 0, 0);
        //noFill();
        //rect(startPos.x + x1 * size, startPos.y + y * size, size, size);
        //rect(startPos.x + x2 * size, startPos.y + y * size, size, size);
        this.left = x2;
        this.right = x1;

        if (x1 >= 0 && x1 < world[0].length && y >= 0 && y < world.length) {
            if (world[y][x1] != null && !world[y][x1].passThrough) {
                startPos.y -= world[y][x1].pos.y - height/2;
                return true;
            }
        }
        if (x2 >= 0 && x2 < world[0].length && y >= 0 && y < world.length) {
            if (world[y][x2] != null && !world[y][x2].passThrough) {
                startPos.y -= world[y][x2].pos.y - height/2;
                return true;
            }
        }
        return false;
    }
}
