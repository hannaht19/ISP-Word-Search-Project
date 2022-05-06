import Scenes
import Igis
import Foundation

  /*
     This class is responsible for rendering the background.
   */

struct GridSelectionType {
    var x: Int
    var y: Int
}

var gridSelection: [GridSelectionType] = []

var storage = [[Character]]()
var fontSize = [[Int]]()
var fontColorCongrats = Int()
var userInput = ""

class SelectTool : RenderableEntity, EntityMouseClickHandler, KeyDownHandler {

    let ellipse = Ellipse(center:Point(x:0, y:0), radiusX:30, radiusY:30, fillMode:.fillAndStroke)
    let strokeStyle = StrokeStyle(color:Color(.orange))
    let fillStyle = FillStyle(color:Color(.red))
    let lineWidth = LineWidth(width:5)

    var countWordsFound = 0
    
    override func setup(canvasSize:Size, canvas:Canvas) {
        dispatcher.registerEntityMouseClickHandler(handler:self)
        dispatcher.registerKeyDownHandler(handler:self)
    }
    
    override func teardown() {
        dispatcher.unregisterEntityMouseClickHandler(handler:self)
        dispatcher.unregisterKeyDownHandler(handler:self)
    }

    func background() -> Background {
        guard let scene = scene as? MainScene else {
            fatalError("MainScene is required to access Background")
        }
        return scene.backgroundLayer.background
    }

    
    func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        let words : [String] = ["BROWN", "RED", "ORANGE", "YELLOW", "GREEN", "BLUE", "INDIGO", "VIOLET"]

        if key == "q" {
            print("Quit out of Game")
            exit(0)
        }
        
        if key == "s" {
            print(userInput)
            print(gridSelection[0].x, gridSelection[0].y)
            print(countWordsFound)
            for i in 0..<words.count {
                print("entering for loop")
                print(words[i])
                if words[i] == userInput {
                    print("good word found")
                    for j in 0..<gridSelection.count {
                        background().changeFont(x:gridSelection[j].x, y:gridSelection[j].y, fontBig:2)
                    }
                    countWordsFound += 1
                    userInput = ""
                    gridSelection = []
                    print(countWordsFound)
                    if countWordsFound == words.count {
                        background().congratsChange(fontColor:1)
                        print("Congratulations! You found all the words")
                    }
                    break
                } else {
                    if i == 7 {
                        print("incorrect word")
                        for j in 0..<gridSelection.count {
                            background().changeFont(x:gridSelection[j].x, y:gridSelection[j].y, fontBig:0)
                        }
                        gridSelection = []
                        userInput = ""
                    } else {
                        print("match not found")
                    }
                }
            }
        } else {
            if key == "c" {
                for j in 0..<gridSelection.count {
                    background().changeFont(x:gridSelection[j].x, y:gridSelection[j].y, fontBig:0)
                }
                userInput = ""
                gridSelection = []
                print("user cancelled")
            }
        }
    }
    
    func onEntityMouseClick(globalLocation: Point) {        
        let result = background().calculateGridLocation(userX:globalLocation.x, userY:(globalLocation.y + 20))
        if result.0 != 999 || result.1 != 999 {
            userInput.append(storage[result.0][result.1])
            gridSelection.append(GridSelectionType(x: result.0, y: result.1))
        }
        for j in 0..<gridSelection.count {
            background().changeFont(x:gridSelection[j].x, y:gridSelection[j].y, fontBig:1)
        }
    }
    
    override func boundingRect() -> Rect {
        return Rect(size: Size(width: Int.max, height: Int.max))
    }    
}



class gridClass {
    
    init() {
        // Create a 15 by 15 two-dimensional array.
        // ... Use append calls.
        for _ in 0..<15 {
            var subArray = [Character]()
            var subArrayFont = [Int]()
            for _ in 0..<15 {
                subArray.append(" ")
                subArrayFont.append(0)
            }
            storage.append(subArray)
            fontSize.append(subArrayFont)
        }
    }

    func randomInt(maxInt:Int, minInt:Int) -> Int {
        // horizontal = 0, vertical = 1
        return Int.random(in: minInt...maxInt)
    }

    func findEmptyLocation(word:String) -> (Int, Int, Int) {
            let wordLength = word.count
            let direction = randomInt(maxInt:1, minInt:0)
            var storedLetter : Character = " "
            var startX = 0
            var startY = 0
            var endX = 0
            var endY = 0
            var canPlaceWord = false
            
            // find empty location in grid to place word
            
            repeat {

                startX = randomInt(maxInt:14, minInt:0)
                startY = randomInt(maxInt:14, minInt:0)
                endX = startX + wordLength
                endY = startY + wordLength
                storedLetter = storage[startX][startY]
                print(word, direction, startX, startY, wordLength, endX, endY)

                if direction == 0 {
                    if endX < 14 {
                        var countEmptyLetters = 0
                        for i in 0..<wordLength {
                            if storage[startX + i][startY] != " " {
                                break
                            } else {
                                countEmptyLetters += 1
                            }
                        }
                        if countEmptyLetters == wordLength {
                            canPlaceWord = true
                        }
                    }               
                } else {
                    if endY < 14 {
                        var countEmptyLetters = 0
                        for i in 0..<wordLength {
                            if storage[startX][startY + i] != " " {
                                break
                            } else {
                                countEmptyLetters += 1
                            }
                        }
                        if countEmptyLetters == wordLength {
                            canPlaceWord = true
                        }
                    }
                }                                  
            } while !canPlaceWord
            return (direction, startX, startY)
    }

    func placeLettersOnGrid(word:String, direction:Int, x:Int, y:Int, i:Int) {
        var letter : Character
        let startX = x
        let startY = y
        let k = word.index(word.startIndex, offsetBy: i)
        letter = word[k]
                
        if direction == 0 {
            storage[startX + i][startY] = letter
            print(direction, startX + i, startY, letter)
        } else {
            storage[startX][startY + i] = letter
            print(direction, startX, startY + i, letter)
        }
    }
    
    func placeWords() {
        let words : [String] = ["BROWN", "RED", "ORANGE", "YELLOW", "GREEN", "BLUE", "INDIGO", "VIOLET"]
        for j in 0..<words.count {
            let word = words[j]                                                                  // get new word from word bank to place in grid 
            let result = findEmptyLocation(word:word)
            for i in 0..<word.count {
                placeLettersOnGrid(word:word, direction:result.0, x:result.1, y:result.2, i:i)   // place each letter horizontally or vertically
            }
        }
    }

    func placeRandomLetters() {
        //let alphabet : [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        let alphabet : [String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        var s : String = ""
        for x in 0..<15 {
            for y in 0..<15 {
                if storage[x][y] == " " {
                    storage[x][y] = Character(alphabet[Int.random(in: 0...25)])
                }
                s.append(storage[x][y])
            }
            print(s)
            s = ""
        }
    }  
    
    subscript(row: Int, column: Int) -> Character {
        get {
            // This could validate arguments.
            return storage[row][column]
        }
        set {
            // This could also validate.
            storage[row][column] = newValue
        }
    }
}


class Background : RenderableEntity {

    let grid = gridClass()
    
    let gridStartX = 125
    let gridIncrX = 30
    let gridStartY = 125
    let gridIncrY = 30

    var text = Text(location: Point.zero, text: "")
    var fillStyle =  FillStyle(color: Color(.orange))
    var font: String = "25pt Arial"
    var congratsFillStyle = FillStyle(color:Color(.white))
    
    func changeFont(x:Int, y:Int, fontBig:Int) {
        fontSize[x][y] = fontBig
    }
    
    func renderWords(canvas:Canvas, letterGrid: [[Character]]) {

        for i in 0..<15 {
            for j in 0..<15 {
                let text = Text(location:Point(x:gridStartX + (gridIncrX * i), y:gridStartY + (gridIncrY * j)), text:"\(letterGrid[i][j])")
                if fontSize[i][j] == 1 {
                    text.font = "22pt Arial"
                    fillStyle = FillStyle(color:Color(.orange))
                } else {
                    if fontSize[i][j] == 2 {
                        text.font = "22pt Arial"
                        fillStyle = FillStyle(color:Color(.green))
                    } else {
                        text.font = "20pt Arial"
                        fillStyle = FillStyle(color:Color(.black))
                    }
                }
                canvas.render(fillStyle, text)
            }
        }
    }

    func renderScore(canvas:Canvas) {
        let score = Text(location:Point(x:700, y:140), text:"Score:")
        score.font = "30pt Arial"
        let scoreFillStyle = FillStyle(color:Color(.black))
        canvas.render(scoreFillStyle, score)
    }
    
    func congratsChange(fontColor:Int) {
        fontColorCongrats = fontColor
    }

    func renderCongratulations(canvas:Canvas) {

        let congrats = Text(location:Point(x:570, y:50), text:"CONGRATS!")
        congrats.font = "30pt Arial"
        if fontColorCongrats == 0 {
            congratsFillStyle = FillStyle(color:Color(.white))
        } else {
            congratsFillStyle = FillStyle(color:Color(.black))
        }
        canvas.render(congratsFillStyle, congrats)        
    }
    
    func renderWordBankWords(canvas:Canvas) {
        let incrX = 650
        var incrY = 330
        var incrY2 = 330
        var a = 0
        var a2 = 0
        let words : [String] = ["BROWN", "RED", "ORANGE", "YELLOW", "GREEN", "BLUE", "INDIGO", "VIOLET"]
        for _ in 0..<(words.count/2) {
            let text1 = Text(location:Point(x:incrX, y:incrY), text:"\(words[0 + a])")
            text1.font = "20pt Arial"
            let fillStyle1 = FillStyle(color:Color(.black))
            canvas.render(fillStyle1, text1)
            a += 1
            incrY += 70
        }
        for _ in 4..<words.count {
            let text2 = Text(location:Point(x:incrX + 150, y:incrY2), text:"\(words[4 + a2])")
            text2.font = "20pt Arial"
            let fillStyle2 = FillStyle(color:Color(.black))
            canvas.render(fillStyle2, text2)
            a2 += 1
            incrY2 += 70
        }
    }

    func renderInstructions(canvas:Canvas) {

        let instructions = Text(location:Point(x:550, y:700), text:"INSTRUCTIONS")
        instructions.font = "20pt Arial"
        let fillStyle3 = FillStyle(color:Color(.black))

        let instructions2 = Text(location:Point(x:310, y:750), text:"Click on each letter until you have a word. Once you've clicked a whole word, press s.")
        instructions2.font = "13pt Arial"
        
        let instructions3 = Text(location:Point(x:310,y:775), text:"If the word is correct, it will turn green, if not, it will return to its normal color.")
        instructions3.font = "13pt Arial"

        let instructions4 = Text(location:Point(x:310, y:800), text:"Press c if you want to clear the letters you've clicked. Press q to end the game.")
        instructions4.font = "13pt Arial"
        
        canvas.render(fillStyle3, instructions, instructions2, instructions3, instructions4)
    }
        
    func renderRectangle(canvas: Canvas, rect: Rect, rInt: Int, gInt: Int, bInt: Int, widthOfLine: Int) {
        let fillStyle = FillStyle(color:Color(red: UInt8(rInt), green: UInt8(gInt), blue: UInt8(bInt)))
        let lineWidth = LineWidth(width: Int(widthOfLine))
        let rectangle = Rectangle(rect: rect, fillMode:.fillAndStroke)
        canvas.render(fillStyle, lineWidth, rectangle)
    }
    
    override func setup(canvasSize:Size, canvas:Canvas) {

        
        let instructionRectangle = Rect(topLeft: Point(x:270, y:650), size:Size(width:830, height:200))
        renderRectangle(canvas:canvas, rect:instructionRectangle, rInt:255, gInt: 255, bInt:255, widthOfLine:4)
        
        renderInstructions(canvas:canvas)
        
        let gridRect = Rect(topLeft: Point(x: 625, y: 275), size: Size(width: 300, height: 300))
        renderRectangle(canvas:canvas, rect:gridRect, rInt:10, gInt:150, bInt:150, widthOfLine:4)

        renderWordBankWords(canvas:canvas)

        grid.placeWords()
        grid.placeRandomLetters()        

    }

    func calculateGridLocation(userX:Int, userY:Int) -> (Int, Int) {
        let gridEndX = gridStartX + (gridIncrX * 15)
        let gridEndY = gridStartY + (gridIncrY * 15)
        
        if userX < gridStartX || userY < gridStartY || userX > gridEndX || userY > gridEndY {
            return (999, 999)
        } else {
            let gridPointX = ((userX - gridStartX) / gridIncrX)
            let gridPointY = ((userY - gridStartY) / gridIncrY)
            print(userX, userY, gridStartX, gridStartY, gridIncrX, gridIncrY, gridPointX, gridPointY)
            return (gridPointX, gridPointY)
        } 
    }
    
    override func render(canvas:Canvas) {
        
        let gridEndX = gridStartX + (gridIncrX * 15)
        let gridEndY = gridStartY + (gridIncrY * 15)
       
        let whiteBackground = Rect(topLeft: Point(x:gridStartX - 20, y:gridStartY - 40), size:Size(width: (gridIncrX * 15) + 30, height: (gridIncrY * 15) + 40))
        renderRectangle(canvas:canvas, rect:whiteBackground, rInt:255, gInt:255, bInt:255, widthOfLine:4)

        renderWords(canvas:canvas, letterGrid:storage)

        renderCongratulations(canvas:canvas)

    }
    

      init() {
          // Using a meaningful name can be helpful for debugging
          super.init(name:"Background")
      }
}
