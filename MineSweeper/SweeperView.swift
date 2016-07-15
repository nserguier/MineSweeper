//
//  SweeperView.swift
//  MineSweeper
//  CIS/CSE 444/651
//  Homework G
//  Created by Nicklos Serguier on 05/04/16.

import UIKit

class SweeperView: UIView {
    
    var dw : CGFloat = 0;  var dh : CGFloat = 0    // width and height of cell
    var touch_x : CGFloat = 0;   var touch_y : CGFloat = 0     // touch point coordinates
    var touch_row : Int = 0; var touch_col : Int = 0; // touch point cell int coodrinates
    
    var firstDoubleTap = true
    let n = 30// number of mines
    var max = 256 //maximum of uncovered cells, reach it to win
    var minesPos: [(Int,Int)] = [] // list of all mine positions
    var grid = Array(count: 16, repeatedValue: Array(count: 16, repeatedValue: UIImage(named: "tile.png"))) // matrix of images for the grid, initially filled with tiles
    var visited = Array(count: 16, repeatedValue: Array(count: 16, repeatedValue: false)) // matrix used for the Depth First Search algorithm, 10x10 filled with false (non visited)
    var nb_visited = 0 //number of uncovered cells
    
    //METHODS
    
    
    //Check if an array of tuples (int,int) contain a particular tuple
    func contains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    
    //Generate random mines
    func randomMines(){
        var index = 0
        while(index<n){
            let i = Int(arc4random_uniform(16))
            let j = Int(arc4random_uniform(16))
            if(!contains(self.minesPos,v: (i,j))){ // check valid position
                self.minesPos.append((i,j))
                index++
            }
        }
    }
    
    //Check if a position is in the grid
    func isInGrid(i: Int,j: Int)->Bool{
        if(0<=i && i<=15 && 0<=j && j<=15){
            return true
        }
        return false
    }
    
    //Get the 8 possible neighbors of a position in the grid
    func neighbors(i: Int,j: Int)->[(Int,Int)]{
        return [(i,j-1),(i,j+1),(i-1,j),(i+1,j),(i-1,j-1),(i-1,j+1),(i+1,j-1),(i+1,j+1)]
    }

    
    // put a flag on the current cell if it is unexplored
    func flag(){
        if(!visited[touch_row][touch_col]){
            grid[self.touch_row][self.touch_col] = UIImage(named: "flag.png")
            setNeedsDisplay()
        }
    }
    
    // gives the number that should appear in the cell
    // -1 for mines, 0 for a blank cell, otherwise 1-8 number of mines around
    func checkAround(i: Int,j: Int)->Int{
        var nb_mines = 0 // number of mines around the point
        if(contains(self.minesPos,v:(i,j))){ // found mine
            return -1
        }
        else{ //check how many mines around
            for (l,m) in neighbors(j,j: i){
                if(isInGrid(l, j: m) && contains(self.minesPos,v:(m,l))){nb_mines++}
            }
        }
        return nb_mines
    }
    
    //Explore from touched cell
    func explore(col: Int,row: Int){
        self.visited[row][col] = true
        nb_visited++
        let nb = self.checkAround(row, j: col)
        changeImage(col, row: row, nb: nb)
        if(nb == 0){
            for (i,j) in neighbors(row, j: col){
                if(isInGrid(i, j: j) && !self.visited[i][j]){
                    explore(j,row: i)
                }
            }
        }
    }
    
    //change image in the cell of the grid accordingly to the number
    //0 is blank, -1 is mine, the rest in the number images
    func changeImage(col: Int, row: Int, nb: Int){
        if(nb == -1){showAllMines()}
        else{
            let str = String(nb) + ".png"
            grid[row][col] = UIImage(named:str)
        }
    }
    
    // show all mines on the grid
    func showAllMines(){
        for (i,j) in minesPos{
            self.grid[i][j] = UIImage(named:"mine.png")
        }
        setNeedsDisplay()
        // game over message:
        let alertController = UIAlertController(title: "GAME OVER", message:
            "Nooo, you just hit a mine!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default,handler: {action in self.reboot()}))
        
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Explore the cell when double tapped
    func doubleTapped(){
        if(firstDoubleTap){ //on first uncover, make sure that we land in a blank
            firstDoubleTap = false
            while(checkAround(touch_row, j: touch_col) != 0){
                minesPos = [] //remove old mines
                randomMines()
            }
            explore(self.touch_col,row: self.touch_row)
            setNeedsDisplay()
        }else{
            explore(self.touch_col,row: self.touch_row)
            setNeedsDisplay()
            if(nb_visited == max){ // Victory
                let alertController = UIAlertController(title: "VICTORY", message:
                    "Congratulations!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default,handler: {action in self.reboot()}))
            
                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //reboot the game with new random mines
    func reboot(){
        for i in 0..<16{
            for j in 0..<16{
                self.grid[i][j] = UIImage(named: "tile.png")
            }
        }
        minesPos = [] //remove old mines
        visited = Array(count: 16, repeatedValue: Array(count: 16, repeatedValue: false)) //unexplored new grid
        firstDoubleTap = true
        nb_visited = 0
        randomMines()
        setNeedsDisplay()
    }
    
    //Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        randomMines()
        max = 256 - self.n
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        randomMines()
        max = 256 - self.n
    }
    
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!  // obtain graphics context
        let bounds = self.bounds          // get view's location and size
        let w = CGRectGetWidth( bounds )   // w = width of view (in points)
        let h = CGRectGetHeight( bounds ) // h = height of view (in points)
        self.dw = w/16.0                      // dw = width of cell (in points)
        self.dh = h/16.0                      // dh = height of cell (in points)
        
        // draw lines to form a 10x10 cell grid
        CGContextBeginPath( context )               // begin collecting drawing operations
        for i in 0..<17 {
            // draw horizontal grid line
            let iF = CGFloat(i)
            CGContextMoveToPoint( context, 0, iF*(self.dh) )
            CGContextAddLineToPoint( context, w, iF*self.dh )
        }
        for i in 0..<17 {
            // draw vertical grid line
            let iFlt = CGFloat(i)
            CGContextMoveToPoint( context, iFlt*self.dw, 0 )
            CGContextAddLineToPoint( context, iFlt*self.dw, h )
        }
        UIColor.grayColor().setStroke()                        // use gray as stroke color
        CGContextDrawPath( context, CGPathDrawingMode.Stroke ) // execute collected drawing ops
        
        // loop over grid to draw images
        for i in 0..<16{
            for j in 0..<16{
                let tile = CGPointMake(CGFloat(j)*self.dw,CGFloat(i)*self.dh)
                let rect = CGRectMake(tile.x, tile.y, dw, dh)
                let img = grid[i][j]
                img?.drawInRect(rect)
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            var xy : CGPoint
            
            for t in touches {
                xy = t.locationInView(self)
                self.touch_x = xy.x;  self.touch_y = xy.y
                self.touch_col = Int(self.touch_x / self.dw);  self.touch_row = Int(self.touch_y / self.dh)
            }
    }
}