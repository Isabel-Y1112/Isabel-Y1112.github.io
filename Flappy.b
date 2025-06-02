<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flappy Bird</title>
    <style>
        body {
    margin: 0;
    padding: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background-color: #70c5ce;
    font-family: Arial, sans-serif;
    overflow: hidden;
}
 
#game-container {
    position: relative;
    width: 450px;
    height: 600px;
    background-color: #70c5ce;
    overflow: hidden;
    border: 3px solid #333;
    border-radius: 5px;L
}
 
#bird {
    position: absolute;
    width: 40px;
    height: 30px;
    background-color: #ffcc00;
    border-radius: 50% 50% 50% 50% / 60% 60% 40% 40%;
    left: 50px;
    top: 300px;
    z-index: 10;
}
 
/* 鸟的翅膀 */
#bird::before {
    content: "";
    position: absolute;
    width: 20px;
    height: 10px;
    background-color: #ff9900;
    border-radius: 50%;
    top: 5px;
    left: -5px;
    transform: rotate(-30deg);
}
 
/* 鸟的眼睛 */
#bird::after {
    content: "";
    position: absolute;
    width: 8px;
    height: 8px;
    background-color: #000;
    border-radius: 50%;
    top: 8px;
    right: 8px;
}

#bird::after:nth-of-type(2) {
    content: "";
    position: absolute;
    width: 0;
    height: 0;
    border-top: 6px solid transparent;
    border-bottom: 6px solid transparent;
    border-left: 10px solid #ffff00;
    top: 50%;
    right: -10px;
    transform: translateY(-50%);
    z-index: 1;
}
 
.pipe {
    position: absolute;
    width: 60px;
    background-color: #5cb85c;
    border: 3px solid #4cae4c;
    border-radius: 5px;
    right: -60px;
}
 
.pipe-top {
    top: 0;
}
 
.pipe-bottom {
    bottom: 0;
}
 
#score {
    position: absolute;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    font-size: 30px;
    color: white;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
    z-index: 100;
}
 
#game-over {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background-color: rgba(0, 0, 0, 0.8);
    color: white;
    padding: 20px;
    border-radius: 10px;
    text-align: center;
    display: none;
    z-index: 200;
}
 
#game-over h2 {
    margin-top: 0;
}
 
#restart-btn {
    background-color: #5cb85c;
    color: white;
    border: none;
    padding: 10px 20px;
    font-size: 16px;
    border-radius: 5px;
    cursor: pointer;
    margin-top: 10px;
}
 
#restart-btn:hover {
    background-color: #4cae4c;
}
 
#start-screen {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    color: white;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    z-index: 150;
}
 
#start-screen h1 {
    font-size: 36px;
    margin-bottom: 20px;
}
 
#start-screen p {
    font-size: 18px;
    animation: blink 1.5s infinite;
}
 
@keyframes blink {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
}
    </style>
</head>
<body>
    <div id="game-container">
        <div id="bird"></div>
        <div id="score">0</div>
        <div id="game-over">
            <h2>game over!</h2>
            <p>final score: <span id="final-score">0</span></p>
            <button id="restart-btn">play again!</button>
        </div>
        <div id="start-screen">
            <h1>Flappy Bird</h1>
            <p>Click on the screen or press the spacebar to start the game</p>
        </div>
    </div>
 
    <script>
       document.addEventListener('DOMContentLoaded',  function() {
           // 游戏变量 
           const bird = document.getElementById('bird'); 
           const gameContainer = document.getElementById('game-container'); 
           const scoreElement = document.getElementById('score'); 
           const gameOverScreen = document.getElementById('game-over'); 
           const finalScoreElement = document.getElementById('final-score'); 
           const restartBtn = document.getElementById('restart-btn'); 
           const startScreen = document.getElementById('start-screen'); 
           
           // 调整后的参数
           let birdPosition = 300;
           let birdVelocity = 0;
           let gravity = 0.5;
           let gameSpeed = 3;
           let isGameOver = false;
           let score = 0;
           let gameStarted = false;
           let pipes = [];
           let pipeGap = 180;       // 增大管道间隙（原150）
           let pipeFrequency = 2000;// 降低生成频率（原1500ms）
           let minPipeHeight = 120; // 新增最小高度限制 
           let maxPipeHeight = 300; // 新增最大高度限制 
           let lastPipeX = 0;       // 记录最后管道位置（防重叠）
           const minPipeDistance = 250; // 管道间最小水平距离 
        
           // 游戏主循环 
           function gameLoop() {
               if (!gameStarted || isGameOver) return;
               
               // 更新鸟的位置（跳跃幅度调整为-8）
               birdVelocity += gravity;
               birdPosition += birdVelocity;
               bird.style.top  = birdPosition + 'px';
               
               checkCollision();
               movePipes();
               checkScore();
               
               requestAnimationFrame(gameLoop);
           }
        
			// 修改后的管道生成函数（修复单管道问题）
			function generatePipe() {
				if (isGameOver || !gameStarted) return;
				
				// 动态计算安全距离（基于游戏速度）
				const safeDistance = Math.max(250,  300 - gameSpeed * 20);
				
				// 获取最近的有效管道位置（而非仅记录lastPipeX）
				const lastValidPipe = pipes.reduce((max,  pipe) => 
					pipe.x > max ? pipe.x : max, 0);
				
				// 只有当新管道能安全生成时才创建 
				if (gameContainer.offsetWidth  - lastValidPipe >= safeDistance) {
					const pipeHeight = Math.floor( 
						Math.random()  * (maxPipeHeight - minPipeHeight) + minPipeHeight 
					);
					
					// 创建管道对（保持原有样式设置）
					const pipePair = [
						{ type: 'top', height: pipeHeight },
						{ type: 'bottom', height: gameContainer.offsetHeight  - pipeHeight - pipeGap }
					].map(pipe => {
						const element = document.createElement('div'); 
						element.className  = `pipe pipe-${pipe.type}`; 
						element.style.height  = `${pipe.height}px`; 
						gameContainer.appendChild(element); 
						return {
							element,
							passed: false,
							x: gameContainer.offsetWidth  
						};
					});
					
					pipes.push(...pipePair); 
				}
				
				// 使用固定间隔调用（不再嵌套setTimeout）
				if (!isGameOver) {
					setTimeout(generatePipe, pipeFrequency);
				}
			}
 
			// 修改后的管道移动函数 
			function movePipes() {
				pipes.forEach((pipe,  index) => {
					pipe.x -= gameSpeed;
					pipe.element.style.right  = `${gameContainer.offsetWidth  - pipe.x}px`;
					
					// 移除屏幕外的管道 
					if (pipe.x < -60) {
						pipe.element.remove(); 
						pipes.splice(index,  1);
					}
				});
			}
        
           // 碰撞检测（保持不变）
           function checkCollision() {
               if (birdPosition < 0 || birdPosition > gameContainer.offsetHeight  - 30) {
                   endGame();
                   return;
               }
               
               const birdRect = bird.getBoundingClientRect(); 
               for (const pipe of pipes) {
                   const pipeRect = pipe.element.getBoundingClientRect(); 
                   if (
                       birdRect.right  > pipeRect.left  &&
                       birdRect.left  < pipeRect.right  &&
                       birdRect.bottom  > pipeRect.top  &&
                       birdRect.top  < pipeRect.bottom  
                   ) {
                       endGame();
                       return;
                   }
               }
           }
        
           // 计分系统（微调难度曲线）
           function checkScore() {
               for (let i = 0; i < pipes.length;  i += 2) {
                   const pipe = pipes[i];
                   
                   if (!pipe.passed  && pipe.x + 60 < 50) {
                       pipe.passed  = true;
                       score++;
                       scoreElement.textContent  = score;
                       
                       // 每5分增加难度（调整幅度减小）
                       if (score % 5 === 0) {
                           gameSpeed += 0.3;    // 原0.5 
                           pipeGap = Math.max(130,  pipeGap - 3); // 原100和5 
                       }
                   }
               }
           }
        
           // 游戏结束（保持不变）
           function endGame() {
               isGameOver = true;
               finalScoreElement.textContent  = score;
               gameOverScreen.style.display  = 'block';
           }
        
           // 重新开始（重置参数）
           function restartGame() {
               pipes.forEach(pipe  => pipe.element.remove()); 
               pipes = [];
               lastPipeX = 0;
               
               birdPosition = 300;
               birdVelocity = 0;
               bird.style.top  = birdPosition + 'px';
               score = 0;
               scoreElement.textContent  = score;
               gameSpeed = 3;
               pipeGap = 180;
               isGameOver = false;
               gameStarted = true;
               
               gameOverScreen.style.display  = 'none';
               gameLoop();
               setTimeout(generatePipe, pipeFrequency);
           }
        
           // 事件监听（跳跃力度调整为-8）
           document.addEventListener('keydown',  function(e) {
               if (e.code  === 'Space') {
                   if (!gameStarted) {
                       startGame();
                   } else if (!isGameOver) {
                       birdVelocity = -8;  // 原-10 
                   }
               }
           });
        
           gameContainer.addEventListener('click',  function() {
               if (!gameStarted) {
                   startGame();
               } else if (!isGameOver) {
                   birdVelocity = -8;  // 原-10 
               }
           });
        
           restartBtn.addEventListener('click',  restartGame);
        
           // 初始化 
           function startGame() {
               gameStarted = true;
               startScreen.style.display  = 'none';
               gameLoop();
               setTimeout(generatePipe, pipeFrequency);
           }
        
           bird.style.top  = birdPosition + 'px';
       });
    </script>
</body>
</html>