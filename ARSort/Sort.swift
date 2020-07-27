//
//  Sort.swift
//  ARSort
//
//  Created by CuiZihan on 2020/7/24.
//  Copyright © 2020 CuiZihan. All rights reserved.
//

import Foundation

public protocol SortDelegate {
    func swap(i: Int, j: Int)
}

public class Sorter {
    var values: [Float]
    var sortDelegate: SortDelegate
    var semphoreDelegate: SemphoreDelegate
    
    enum algorithm {
        case bubbleSort
        case quickSort
        case insertSort
    }
    
    init(for values: [Float], sortDelegate: SortDelegate, semphoreDelegate: SemphoreDelegate) {
        self.values = values
        self.semphoreDelegate = semphoreDelegate
        self.sortDelegate = sortDelegate
    }
    
    func sort(using alg: Sorter.algorithm) {
        switch alg {
        case .bubbleSort:
            bubbleSort()
        case .quickSort:
            quickSort()
        case .insertSort:
            insertSort()
        }
    }
    
    func bubbleSort() {
        let n: Int = values.count
        for i in 0..<n-1 {
            for j in 0..<n-i-1 {
                if values[j] > values[j+1] {
                    self.semphoreDelegate.getSemphore()
                    self.semphoreDelegate.getSemphore()
                    print("animation completed")
                    print("Sorter get semphore, ready to swap two box")
                    self.semphoreDelegate.releaseSemphore()
                    self.semphoreDelegate.releaseSemphore()
                    print("Sorter release semphore and call swap")
                    self.sortDelegate.swap(i: j, j: j+1)
                    print("swap finished")
                    let temp = values[j]
                    values[j] = values[j+1]
                    values[j+1] = temp
                    print("waiting for animation")
                }
            }
        }
        print("values: \(values)")
    }
    
    func partition(begin: Int, end : Int)->Int {
        let pivot = values[begin]
        var splitPoint = begin
        for i in begin + 1...end {
            if pivot > values[i] {
                splitPoint += 1
                if splitPoint != i {
                    self.semphoreDelegate.getSemphore()
                    self.semphoreDelegate.getSemphore()
                    print("animation completed")
                    print("Sorter get semphore, ready to swap two box")
                    self.semphoreDelegate.releaseSemphore()
                    self.semphoreDelegate.releaseSemphore()
                    print("Sorter release semphore and call swap")
                    self.sortDelegate.swap(i: splitPoint, j: i)
                    print("swap finished")
                    let temp = values[i]
                    values[i] = values[splitPoint]
                    values[splitPoint] = temp
                    print("waiting for animation")
                }
            }
        }
        
        self.semphoreDelegate.getSemphore()
        self.semphoreDelegate.getSemphore()
        print("animation completed")
        print("Sorter get semphore, ready to swap two box")
        self.semphoreDelegate.releaseSemphore()
        self.semphoreDelegate.releaseSemphore()
        print("Sorter release semphore and call swap")
        self.sortDelegate.swap(i: begin, j: splitPoint)
        print("swap finished")
        values[begin] = values[splitPoint]
        values[splitPoint] = pivot
        print("waiting for animation")
        
        return splitPoint
    }
    
    func subQuickSort(begin: Int, end: Int) {
        if begin < end {
            let mid = partition(begin: begin, end: end)
            subQuickSort(begin: begin, end: mid)
            subQuickSort(begin: mid+1, end: end)
        }
    }
    
    func quickSort() {
        subQuickSort(begin: 0, end: self.values.count - 1)
    }
    
    func insertSort() {
        let n = values.count
        for i in 1..<n {
            for j in (1...i).reversed() {
                if values[j] < values[j-1] {
                    self.semphoreDelegate.getSemphore()
                    self.semphoreDelegate.getSemphore()
                    print("animation completed")
                    print("Sorter get semphore, ready to swap two box")
                    self.semphoreDelegate.releaseSemphore()
                    self.semphoreDelegate.releaseSemphore()
                    print("Sorter release semphore and call swap")
                    self.sortDelegate.swap(i: j-1, j: j)
                    print("swap finished")
                    let temp = values[j]
                    values[j] = values[j-1]
                    values[j-1] = temp
                }
            }
        }
    }
}
