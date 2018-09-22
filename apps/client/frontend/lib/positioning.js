const calcRatio = (dimensions, board) => {
  const { width, height } = dimensions;
  const { width: boardWidth, height: boardHeight } = board;

  return {
    widthRatio: width / boardWidth,
    heightRatio: height / boardHeight,
  };
};

const repositionPaddle = (dimensions, ratios, paddle) => {
  const { height } = dimensions;
  const { widthRatio, heightRatio } = ratios;

  const paddleHeight = paddle.height * heightRatio;
  const paddleWidth = paddle.width * widthRatio;
  const paddleX = paddle.x * widthRatio - paddleWidth / 2;
  const paddleY = height - (paddle.y * heightRatio - paddleHeight / 2);

  return {
    height: paddleHeight,
    width: paddleWidth,
    x: paddleX,
    y: paddleY,
  };
};

const repositionBall = (dimensions, ratios, ball) => {
  const { height } = dimensions;
  const { widthRatio, heightRatio } = ratios;

  return {
    x: widthRatio * ball.x,
    y: height - heightRatio * ball.y,
    radius: widthRatio * ball.radius,
  };
};

const repositionGame = ({ dimensions, game }) => {
  const {
    ball,
    board,
    paddle_left: paddleLeft,
    paddle_right: paddleRight,
  } = game;

  const ratios = calcRatio(dimensions, board);

  const repositionedPaddleLeft = repositionPaddle(
    dimensions,
    ratios,
    paddleLeft
  );

  const repositionedPaddleRight = repositionPaddle(
    dimensions,
    ratios,
    paddleRight
  );

  const repositionedBall = repositionBall(dimensions, ratios, ball);

  return {
    board,
    ball: repositionedBall,
    paddle_left: repositionedPaddleLeft,
    paddle_right: repositionedPaddleRight,
  };
};

export default { repositionGame };
