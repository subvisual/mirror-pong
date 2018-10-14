import { Animation } from 'konva';

import positioning from './positioning';
import Channel from './channel';

export default class GameAnimator {
  constructor({ layer, paddleLeft, paddleRight, ball, width, height }) {
    this.layer = layer;
    this.paddleLeft = paddleLeft;
    this.paddleRight = paddleRight;
    this.ball = ball;
    this.width = width;
    this.height = height;
    this.animation = new Animation(this.animate, this.layer);

    this.channel = new Channel('game:board');
    this.joinChannel();
  }

  joinChannel = async () => {
    try {
      await this.channel.join();

      console.log('Joined successfully'); // eslint-disable-line

      this.subscribeToData();
    } catch (error) {
      console.log('Unable to join', resp); // eslint-disable-line
    }
  };

  leaveChannel = async () => {
    try {
      const response = await this.channel.leave();

      console.log('Left successfully', response); // eslint-disable-line
    } catch (error) {
      console.log('Error while leaving the channel', error); // eslint-disable-line
    }
  };

  setDimensions = (width, height) => {
    this.width = width;
    this.height = height;
  };

  subscribeToData = () => {
    this.channel.on('data', data => {
      const { width, height } = this;

      const newPositions = positioning.repositionGame({
        dimensions: { width, height },
        game: data,
      });

      this.setPositions(newPositions);
    });
  };

  animate = () => {
    if (!this.positions) return;

    const { paddleLeft, paddleRight, ball } = this.positions;

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
