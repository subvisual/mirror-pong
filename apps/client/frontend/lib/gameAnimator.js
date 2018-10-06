import { Animation } from 'konva';

export default class GameAnimator {
  constructor({ layer, stage, paddleLeft, paddleRight, ball }) {
    this.layer = layer;
    this.stage = stage;
    this.paddleLeft = paddleLeft;
    this.paddleRight = paddleRight;
    this.ball = ball;
    this.animation = new Animation(this.animate, this.layer);
  }

  animate = () => {
    if (!this.positions) return;

    const { paddleLeft, paddleRight, ball, width, height } = this.positions;

    this.stage.setHeight(height);
    this.stage.setWidth(width);
    this.paddleLeft.setY(paddleLeft.y - paddleLeft.height / 2);
    this.paddleLeft.setX(paddleLeft.x);
    this.paddleRight.setY(paddleRight.y - paddleRight.height / 2);
    this.paddleRight.setX(paddleRight.x);
    this.ball.setX(ball.x);
    this.ball.setY(ball.y);
  };

  setPositions = positions => {
    this.positions = positions;
  };

  start() {
    this.animation.start();
  }

  stop() {
    this.animation.stop();
  }
}
