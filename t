	<!DOCTYPE html>
	<html lang="en">

	<head>
		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Tetris</title>
		<style>
			* {
				box-sizing: border-box;
			}

			#container {
				position: relative;
				display: flex;
				flex-wrap: wrap;
				width: 200px;
				background-color: rgb(37, 31, 57);
			}

			#end {
				text-align: center;
				background-color: rgb(219, 207, 207);
				font-size: 25px;
				width: 80%;
				color: rgb(28, 24, 24);
				font-weight: 700;
				position: absolute;
				top: 30%;
				left: 50%;
				transform: translate(-50%, -50%);
			}

			.cell {
				width: 20px;
				height: 20px;
			}

			.row {
				display: flex;

			}

			.w {
				background-color: white;
				border: 1px solid rgb(46, 44, 44);
			}

			.hidden {
				display: none;
			}
		</style>
	</head>

	<body>
		<div id="container">
			<div id="end" class="hidden"><span>Game Over</span></div>
		</div>
		<button id="start">Start</button>
		<button class="hidden" id="reset">Reset</button>
		<script>
			'use strict';

			let cellCount = 10;
			let rowsCount = 21;

			let container = document.getElementById('container');
			let cell = "<div class='cell'></div>";
			let row = "<div class='row'>";
			let start = document.getElementById('start');
			let reset = document.getElementById('reset');
			let end = document.getElementById('end');

			let posType = ['a', 'b', 'c', 'd'];
			let posNum = 0;
			let newOne = false;

			let gameInterval;
			let updateInterval;

			for (let i = 0; i < cellCount; i++) {
				row += cell;
			}

			for (let i = 0; i < rowsCount; i++) {
				container.insertAdjacentHTML('beforeend', row + "</div>");
			}

			let cells = Array.from(document.querySelectorAll('.cell'));
			let rows = Array.from(document.querySelectorAll('.row'));

			rows[0].style.display = 'none';
			rows.shift();
			let arr = rows[0];

			let tileType = ['i', 'l', 'j', 'o', 't', 's', 'z'];

			let startingPosition = {
				i: [5, 15, 25, 35],
				l: [4, 14, 24, 25],
				j: [5, 15, 25, 24],
				o: [4, 5, 14, 15],
				t: [5, 16, 15, 14],
				s: [4, 14, 15, 25],
				z: [5, 15, 14, 24]
			};

			let tile = {
				type: null,
				position: [],
				v: 'a',
			}

			let area = {
				fixed: new Set(),
			}

			function randomTileType(type) {
				let rand = Math.random() * (type.length);
				return type[Math.floor(rand)];
			}

			function appearanceOfNewElement() {
				let type = randomTileType(tileType);
				tile.type = type;
				tile.position = startingPosition[type].concat();
				posNum = 0;
				tile.v = 'a';
				return tile;
			}

			function render(obj) {
				obj.position.forEach(elem => {
					cells.forEach((item, index) => {
						if (elem == index) {
							item.classList.add('w');
						}
					})
				});
				Array.from(area.fixed).forEach(elem => {
					cells.forEach((item, index) => {
						if (elem == index) {
							item.classList.add('w');
						}
					})
				});
				return obj;
			}

			function clear() {
				cells.forEach(item => item.classList.remove('w'));
			}

			function update(obj) {
				obj.position = obj.position.map(item => item += 10);
				return obj;
			}

			function save(obj) {
				if (obj.position.some(item => item > (cellCount * rowsCount - 11))) {
					newOne = true;
					obj.position.forEach(item => {
						area.fixed.add(item);
					});
					return rows;

				} else if (obj.position.some(elem => {
					return Array.from(area.fixed).some(item => {
						return elem + 10 == item;
					})
				})) {
					newOne = true;
					obj.position.forEach(item => {
						area.fixed.add(item);
					})
					return rows;

				} else {
					return rows;
				}
			}

			function wipeOut(rows) {
				let arr = [];
				rows.forEach(item => {
					let row = Array.from(item.querySelectorAll('.cell'))
					let fullLineAsBoolean = row.every(elem => {
						return elem.classList.contains('w');
					})
					arr.push(fullLineAsBoolean);
				});


				let count = 0;
				let fullLines = [];
				let lineCount = -1;

				arr.forEach((item, index) => {
					if (!item) return;
					++count;
					fullLines.push(index * 10 + 19);
					for (let i = index * 10 + 19; i != index * 10 + 9; i--) {
						area.fixed.delete(i);
					}
				})
				for (let i = 0; i < count; i++) {
					++lineCount;
					let set = new Set(area.fixed);
					area.fixed.clear();
					area.fixed = new Set(Array.from(set).map(item => {
						item = (item <= (fullLines[lineCount] - 10)) ? (item + 10) : item;
						return item;
					}));
				}
			}
			function over() {
				if (Array.from(area.fixed).some(item => item <= 19)) {
					end.classList.remove('hidden')
					clearInterval(updateInterval);
					clearInterval(gameInterval);
				}
			}

			start.addEventListener('click', function () {
				start.classList.add('hidden');
				reset.classList.remove('hidden');

				newOne = true;
				updateInterval = setInterval(() => {
					clear();
					render(tile);
				}, 16);

				gameInterval = setInterval(() => {
					new Promise(resolve => {
						if (newOne) {
							appearanceOfNewElement();
							newOne = false;
						}
						if (!checkTheObstacleBelow(tile)) {
							resolve(update(tile));
						} else {
							resolve(tile);
						}
					}).then(result => {
						return new Promise(resolve => {
							setTimeout(() => resolve(save(result)), 900);
						});
					}).then(result => {
						wipeOut(result);
					}).then(() => over());

				}, 1000);
			});
			reset.addEventListener('click', function () {
				clearInterval(gameInterval);
				clearInterval(updateInterval);
				tile.type = null;
				tile.position = [];
				tile.v = 'a';
				area.fixed.clear();
				clear();
				reset.classList.add('hidden');
				start.classList.remove('hidden');
				end.classList.add('hidden');
			});
			document.addEventListener('keydown', function (event) {
				if (newOne || !tileType) return;
				switch (event.key) {
					case 'ArrowLeft':
						moveLeft();
						break;
					case 'ArrowRight':
						moveRight();
						break;
					case 'ArrowDown':
						moveDown();
						break;
					case 'ArrowUp':
						rotate(tile);
						break;
				}
			});

			function moveLeft() {
				let obstacleOnTheLeft = checkTheNumberOfCells(tile, 'left', 0);
				if (!obstacleOnTheLeft && !newOne) {
					tile.position = tile.position.map(item => --item);
				}
			}

			function moveRight() {
				let obstacleOnTheRight = checkTheNumberOfCells(tile, 'right', 0);
				if (!obstacleOnTheRight && !newOne) {
					tile.position = tile.position.map(item => ++item);
				}
			}

			function moveDown() {
				if (newOne || checkTheObstacleBelow(tile)) return;
				update(tile);
			}

			function checkTheObstacleBelow(obj) {
				return Array.from(area.fixed).some(item => {
					return obj.position.some(elem => item == elem + 10);
				}) ? true : obj.position.some(item => item > (cellCount * rowsCount - 11));
			}
			function checkTheNumberOfCells(obj, direction, number) {
				let sign = (direction == 'left') ? -1 : 1;
				let directionNumber = (direction == 'left') ? 0 : 1;

				return obj.position.some(item => {
					return (item + (number * sign + directionNumber)) % 10 == 0;
				}) ? true : obj.position.some(item => {
					return Array.from(area.fixed).some(elem => {
						return elem == (item + (1 + number) * sign);
					})
				});

			}
			function changePosition(obj, a, b, c, d) {
				obj.position[0] += a;
				obj.position[1] += b;
				obj.position[2] += c;
				obj.position[3] += d;
				obj.v = posType[++posNum];
			}

			function checkObstacle(all, obj, pos, num) {
				if (all) {
					return Array.from(area.fixed).some(item => {
						return item == (obj.position[pos] + num);
					}) ? true : obj.position[pos] > (cellCount * rowsCount - 21);
				}
				return Array.from(area.fixed).some(item => {
					return item == obj.position[pos] + num;
				});
			}
			function compPosType(type) {
				return tile.v == posType[type];
			}
			function iPos(obj) {
				if (posNum == 3) {
					posNum = -1;
				}

				let obstacleOnTheLeft = checkTheNumberOfCells(obj, 'left', 0);
				let obstacleOnTheRight = checkTheNumberOfCells(obj, 'right', 0);
				let oneCellToTheLeft = checkTheNumberOfCells(obj, 'left', 1);
				let oneCellToTheRight = checkTheNumberOfCells(obj, 'right', 1);
				let twoCellToTheLeft = checkTheNumberOfCells(obj, 'left', 2);
				let twoCellToTheRight = checkTheNumberOfCells(obj, 'right', 2);

				if (((oneCellToTheLeft && oneCellToTheRight)
					|| (twoCellToTheLeft && obstacleOnTheRight)
					|| (twoCellToTheRight && obstacleOnTheLeft)
					|| (oneCellToTheLeft && obstacleOnTheRight)
					|| (obstacleOnTheRight && oneCellToTheLeft)
					|| (obstacleOnTheLeft && oneCellToTheRight)
					|| (obstacleOnTheRight && obstacleOnTheLeft)) && (compPosType(0) || compPosType(2))) {
					return;
				}
				if ((compPosType(1) || compPosType(3)) && checkObstacle(true, obj, 2, 20)) return;

				if (obstacleOnTheRight && (compPosType(0) || compPosType(2))) {
					changePosition(obj, 7, -2, -11, -20);
					return;
				}
				if (obstacleOnTheLeft && (compPosType(0) || compPosType(2))) {
					changePosition(obj, 10, 1, -8, -17);
					return;
				}
				if (oneCellToTheLeft && (compPosType(0) || compPosType(2))) {
					changePosition(obj, 9, 0, -9, -18);
					return;
				}
				if (compPosType(0) || compPosType(2)) {
					changePosition(obj, 8, -1, -10, -19);
					return;
				}
				if (compPosType(1) || compPosType(3)) {
					changePosition(obj, -8, 1, 10, 19);
					return;
				}
			}
			function lPos(obj) {
				if (posNum == 3) {
					posNum = -1;
				}

				let obstacleOnTheLeft = checkTheNumberOfCells(obj, 'left', 0);
				let obstacleOnTheRight = checkTheNumberOfCells(obj, 'right', 0);

				if (((obstacleOnTheLeft && obstacleOnTheRight)
					&& (compPosType(0) || compPosType(2)))
					|| (obstacleOnTheRight && checkObstacle(false, obj, 3, 9) && compPosType(2))
					|| (compPosType(1) && checkObstacle(true, obj, 0, 20))) {
					return;
				}

				if (obstacleOnTheRight && compPosType(0)) {
					changePosition(obj, 11, 0, -11, -2);
					return;
				}

				if (obstacleOnTheLeft && compPosType(2)) {
					changePosition(obj, -11, 0, 11, 2)
					return;
				}

				switch (obj.v) {
					case posType[0]:
						changePosition(obj, 12, 1, -10, -1);
						break;
					case posType[1]:
						changePosition(obj, 20, 11, 2, -9);
						break;
					case posType[2]:
						changePosition(obj, -12, -1, 10, 1);

						break;
					case posType[3]:
						changePosition(obj, -20, -11, -2, 9);

						break;
				}

			}
			function jPos(obj) {
				if (posNum == 3) {
					posNum = -1;
				}
				let obstacleOnTheLeft = checkTheNumberOfCells(obj, 'left', 0);
				let obstacleOnTheRight = checkTheNumberOfCells(obj, 'right', 0);

				if (((obstacleOnTheLeft && obstacleOnTheRight)
					&& (compPosType(0) || compPosType(2)))
					|| (compPosType(0) && obstacleOnTheRight && checkObstacle(false, obj, 3, -11))
					|| (compPosType(1) && checkObstacle(false, obj, 3, -10))
					|| (compPosType(3)
						&& checkObstacle(false, obj, 3, 9) && checkObstacle(false, obj, 1, 20))
					|| (compPosType(3) && checkTheObstacleBelow(obj))) {
					return;
				}

				if (obstacleOnTheRight && compPosType(2)) {
					changePosition(obj, -21, -10, 1, 10);
					return;
				}
				if (obstacleOnTheLeft && compPosType(0)) {
					changePosition(obj, 21, 10, -1, -10);
					return;
				}

				switch (obj.v) {
					case posType[0]:
						changePosition(obj, 20, 9, -2, -11);
						break;
					case posType[1]:
						changePosition(obj, -2, -11, -20, -9);
						break;
					case posType[2]:
						changePosition(obj, -20, -9, 2, 11);
						break;
					case posType[3]:
						changePosition(obj, 2, 11, 20, 9);
						break;
				}

			}
			function sPos(obj) {
				if (posNum == 3) {
					posNum = -1;
				}

				let obstacleOnTheLeft = checkTheNumberOfCells(obj, 'left', 0);
				let obstacleOnTheRight = checkTheNumberOfCells(obj, 'right', 0);

				if (((obstacleOnTheLeft && obstacleOnTheRight)
					&& (compPosType(0) || compPosType(2)))
					|| (compPosType(3) && checkObstacle(false, obj, 3, 20))
					|| (compPosType(3) && checkTheObstacleBelow(obj))) {
					return;
				}

				if (compPosType(0) && obstacleOnTheRight) {
					changePosition(obj, 11, 0, 9, -2);
					return;
				}
				if (compPosType(2) && obstacleOnTheLeft) {
					changePosition(obj, -11, 0, -9, 2);
					return;
				}

				switch (obj.v) {
					case posType[0]:
						changePosition(obj, 12, 1, 10, -1);
						break;
					case posType[1]:
						changePosition(obj, 9, 0, -11, -20);
						break;
					case posType[2]:
						changePosition(obj, -12, -1, -10, 1);
						break;
					case posType[3]:
						changePosition(obj, -9, 0, 11, 20);
						break;
				}
			}
			function zPos(obj) {
				if (posNum == 3) {
					posNum = -1;
				}

				let obstacleOnTheLeft = checkTheNumberOfCells(obj, 'left', 0);
				let obstacleOnTheRight = checkTheNumberOfCells(obj, 'right', 0);

				if (((obstacleOnTheLeft && obstacleOnTheRight)
					&& (compPosType(0) || compPosType(2)))
					|| (compPosType(0) && checkObstacle(false, obj, 2, 12) && !obstacleOnTheRight)
					|| (compPosType(3) && checkTheObstacleBelow(obj))) {
					return;
				}

				if (compPosType(2) && obstacleOnTheLeft) {
					changePosition(obj, -20, -9, 0, 11);
					return;
				}
				if (compPosType(0) && obstacleOnTheRight) {
					changePosition(obj, 20, 9, 0, -11);
					return;
				}

				switch (obj.v) {
					case posType[0]:
						changePosition(obj, 21, 10, 1, -10);
						break;
					case posType[1]:
						changePosition(obj, -2, -11, 0, -9);
						break;
					case posType[2]:
						changePosition(obj, -21, -10, -1, 10);
						break;
					case posType[3]:
						changePosition(obj, 2, 11, 0, 9);
						break;
				}
			}
			function tPos(obj) {
				if (posNum == 3) {
					posNum = -1;
				}

				let obstacleOnTheLeft = checkTheNumberOfCells(obj, 'left', 0);
				let obstacleOnTheRight = checkTheNumberOfCells(obj, 'right', 0);

				if (((obstacleOnTheLeft && obstacleOnTheRight)
					&& (compPosType(1) || compPosType(3)))
					|| ((compPosType(0) || compPosType(2)) && checkTheObstacleBelow(obj))) {
					return;
				}

				if (compPosType(1) && obstacleOnTheLeft) {
					changePosition(obj, 10, -10, 1, 12);
					return;
				}
				if (compPosType(3) && obstacleOnTheRight) {
					changePosition(obj, -10, 10, -1, -12);
					return;
				}

				switch (obj.v) {
					case posType[0]:
						changePosition(obj, 11, 9, 0, -9);
						break;
					case posType[1]:
						changePosition(obj, 9, -11, 0, 11);
						break;
					case posType[2]:
						changePosition(obj, -1, 1, 10, 19);
						break;
					case posType[3]:
						changePosition(obj, -9, 11, 0, -11);
						break;
				}
			}
			function rotate(obj) {
				if (obj.type == 'o') return;

				new Promise(resolve => {
					switch (obj.type) {
						case 'i':
							resolve(iPos(obj));
							break;
						case 'l':
							resolve(lPos(obj));
							break;
						case 'j':
							resolve(jPos(obj));
							break;
						case 's':
							resolve(sPos(obj));
							break;
						case 'z':
							resolve(zPos(obj));
							break;
						case 't':
							resolve(tPos(obj));
							break;
					}
				}).then(() => {
					save(tile);
				});
			}
		</script>
	</body>

	</html>
