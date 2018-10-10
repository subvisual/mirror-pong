import { Animation } from 'konva';
import { Socket } from 'phoenix';

import positioning from './positioning';

export default class GameAnimator {
  constructor({ layer, paddleLeft, paddleRight, ball, width, height }) {
    this.layer = layer;
    this.paddleLeft = paddleLeft;
    this.paddleRight = paddleRight;
    this.ball = ball;
    this.width = width;
    this.height = height;
    this.animation = new Animation(this.animate, this.layer);

    this.socket = new Socket('/socket');

    this.socket.connect();
    this.channel = this.socket.channel('game:board');
    this.joinChannel();
  }

  joinChannel = () => {
    this.channel
      .join()
      .receive('ok', () => {
        console.log('Joined successfully'); // eslint-disable-line
        this.subscribeToData();
      })
      .receive('error', resp => {
        console.log('Unable to join', resp); // eslint-disable-line
      });
  };

  leaveChannel = () => {
    this.channel
      .leave()
      .receive('ok', resp => {
        console.log('Left successfully', resp); // eslint-disable-line
        this.socket.disconnect();
      })
      .receive('error', resp => {
        console.log('Could not leave the channel!', resp); // eslint-disable-line
        this.socket.disconnect();
      });
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
