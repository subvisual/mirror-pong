const calcRatio = (dimensions, board) => {
  const { width, height } = dimensions;
  const { width: boardWidth, height: boardHeight } = board;

  return {
    widthRatio: width / boardWidth,
    heightRatio: height / boardHeight,
  };
};

const repositionPaddle = (
  dimensions,
  ratios,
  paddle,
  relativeToFullWidth = false
) => {
  const { height } = dimensions;
  const { widthRatio, heightRatio } = ratios;

  const paddleHeight = paddle.height * heightRatio;
  const paddleWidth = paddle.width * widthRatio;
  const paddleY = height - paddle.y * heightRatio;
  const paddleX = relativeToFullWidth
    ? paddle.x * widthRatio
    : paddle.x * widthRatio - paddleWidth;

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
    paddleRight,
    true
  );

  const repositionedBall = repositionBall(dimensions, ratios, ball);

  return {
    ...game,
    ...dimensions,
    ball: repositionedBall,
    paddleLeft: { ...paddleLeft, ...repositionedPaddleLeft },
    paddleRight: { ...paddleRight, ...repositionedPaddleRight },
  };
};

export default { repositionGame };
