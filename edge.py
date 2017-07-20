from collections import deque
import os
import numpy as np
import argparse
import cv2
import cv2.cv as cv
from random import randint
# import imutils

cam = cv2.VideoCapture(1)
pts = deque(maxlen=64)

def add_chip_to_board(chip, color):
    if minX == None or minY == None or maxY == None or maxY == None: return
    try:
        x_index = (chip[0] - minX) / averageXDistance
        y_index = 9 - ((chip[1] - minY) / averageYDistance)
        board_state[x_index][y_index] = color
    except:
        pass

def show_scoring_move(row, column, color):
    if minX == None or minY == None or maxY == None or maxY == None: return
    try:
        move_x = row * averageXDistance + minX + averageXDistance - 70 + randint(0, 3)
        move_y = (9 - column) * averageYDistance + minY + 45 + randint(0, 3)
        if color == "B":
            bgr = (255, 0, 0)
        if color == "G":
            bgr = (0, 255, 0)
        cv2.circle(img, (move_x, move_y), 32, bgr, 2)
    except:
        pass


while True:
    print "-"
    board_state = [
            ["W", "O", "O", "O", "O", "O", "O", "O", "O", "W"],
            ["O", "O", "O", "O", "O", "O", "O", "O", "O", "O"],
            ["O", "O", "O", "O", "O", "O", "O", "O", "O", "O"],
            ["O", "O", "O", "O", "O", "O", "O", "O", "O", "O"],
            ["O", "O", "O", "O", "O", "O", "O", "O", "O", "O"],
            ["O", "O", "O", "O", "O", "O", "O", "O", "O", "O"],
            ["O", "O", "O", "O", "O", "O", "O", "O", "O", "O"],
            ["O", "O", "O", "O", "O", "O", "O", "O", "O", "O"],
            ["O", "O", "O", "O", "O", "O", "O", "O", "O", "O"],
            ["W", "O", "O", "O", "O", "O", "O", "O", "O", "W"],
    ]

    minX = None
    minY = None
    maxX = None
    maxY = None
    averageXDistance = None
    averageYDistance = None

    ret_val, img = cam.read()
    orig = img

    # img = img[10:950, 540:3200]

    # img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    cimg = cv2.cvtColor(orig,cv2.COLOR_BGR2GRAY)


    # bilateral_filtered_image = cv2.bilateralFilter(img, 5, 175, 175)
    #
    # edge_detected_image = cv2.Canny(bilateral_filtered_image, 60, 150)
    #
    # contours, _= cv2.findContours(edge_detected_image, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    #
    # contour_list = []
    # for contour in contours:
    #     approx = cv2.approxPolyDP(contour,0.01*cv2.arcLength(contour,True),True)
    #     area = cv2.contourArea(contour)
    #     if (area > 800):
    #         contour_list.append(contour)

    # img = edge_detected_image
    # img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    # cv2.drawContours(img, contour_list, -1, (0, 255, 255), 1)

    boundaries = cv2.HoughCircles(cimg,cv.CV_HOUGH_GRADIENT,1,10,param1=50,param2=30,minRadius=27,maxRadius=31)

    if isinstance(boundaries, np.ndarray):
        boundaries = np.uint16(np.around(boundaries))
        for i in boundaries[0,:]:
            cv2.circle(img, (i[0], i[1]), 28, (255, 255, 255), cv.CV_FILLED)
            if minX == None or i[0] < minX:
                minX = i[0] - 70
            if minY == None or i[1] < minY:
                minY = i[1] - 45
            if maxX == None or i[0] > maxX:
                maxX = i[0] + 70
            if maxY == None or i[1] > maxY:
                maxY = i[1] + 45
        averageXDistance = (maxX - minX) / 10
        averageYDistance = (maxY - minY) / 10

    hsv = cv2.cvtColor(orig, cv2.COLOR_BGR2HSV)

    lower_blue = np.array([110,50,50])
    upper_blue = np.array([130,255,255])

    blue_mask = cv2.inRange(hsv, lower_blue, upper_blue)
    blue_mask = cv2.erode(blue_mask, None, iterations=2)
    blue_mask = cv2.dilate(blue_mask, None, iterations=2)
    blue_cnts = cv2.findContours(blue_mask.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2]

    blue_chips = []

    if len(blue_cnts) > 0:
        for c in blue_cnts:
            ((x, y), radius) = cv2.minEnclosingCircle(c)
            if radius > 25 and radius < 50 and x > minX and y > minY and x < maxX and y < maxY:
                M = cv2.moments(c)
                center = (int(M["m10"] / M["m00"]), int(M["m01"] / M["m00"]))
                add_chip_to_board(center, "B")
                cv2.circle(img, (int(x), int(y)), int(radius), (255, 0, 0), cv.CV_FILLED)


    lower_green = np.array([50,50,50])
    upper_green = np.array([90,255,255])

    green_mask = cv2.inRange(hsv, lower_green, upper_green)
    green_mask = cv2.erode(green_mask, None, iterations=2)
    green_mask = cv2.dilate(green_mask, None, iterations=2)
    green_cnts = cv2.findContours(green_mask.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2]

    if len(green_cnts) > 0:
        for c in green_cnts:
            ((x, y), radius) = cv2.minEnclosingCircle(c)
            if radius > 25 and radius < 40 and x > minX and y > minY and x < maxX and y < maxY:
                M = cv2.moments(c)
                center = (int(M["m10"] / M["m00"]), int(M["m01"] / M["m00"]))
                add_chip_to_board(center, "G")
                cv2.circle(img, (int(x), int(y)), int(radius), (0, 255, 0), cv.CV_FILLED)

    lower_red = np.array([160,50,50])
    upper_red = np.array([210,255,255])

    red_mask = cv2.inRange(hsv, lower_red, upper_red)
    red_mask = cv2.erode(red_mask, None, iterations=2)
    red_mask = cv2.dilate(red_mask, None, iterations=2)
    red_cnts = cv2.findContours(red_mask.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2]

    if len(red_cnts) > 0:
        for c in red_cnts:
            ((x, y), radius) = cv2.minEnclosingCircle(c)
            if radius > 25 and radius < 40 and x > minX and y > minY and x < maxX and y < maxY:
                M = cv2.moments(c)
                center = (int(M["m10"] / M["m00"]), int(M["m01"] / M["m00"]))
                add_chip_to_board(center, "R")
                cv2.circle(img, (int(x), int(y)), int(radius), (0, 0, 255), cv.CV_FILLED)


    if isinstance(boundaries, np.ndarray) and boundaries.size == 12 and minY != None and maxY != None and minX != None and maxX != None:
        try:
            font = cv2.FONT_HERSHEY_SIMPLEX
            score = os.popen('ruby solver.rb ' + ''.join(map(str, board_state))).read().splitlines()
            print score
            blue_scoring_move = eval(score[0])
            green_scoring_move = eval(score[1])
            for move in blue_scoring_move:
                show_scoring_move(move[0], move[1], "B")
            for move in green_scoring_move:
                show_scoring_move(move[0], move[1], "G")

            blue_score = score[2]
            green_score = score[3]
            # print blue_scoring_move
            # cv2.rectangle(img, (minX, minY1), (minX + 300, minY + 50), (255,255,255), 2)
            cv2.rectangle(img, (minX + 50, minY - 50), (minX + 400, minY), (255,255,255), cv.CV_FILLED)

            if blue_score == "2":
                os.system('say Blue won!')
            if green_score == "2":
                os.system('say Green won!')

            cv2.putText(img, "Blue: " + blue_score, (minX + 100, minY - 10), font, 1, (255,0,0), 2)
            cv2.putText(img, "Green: " + green_score, (minX + 250, minY - 10), font, 1, (0,205,0), 2)
            for angle in np.arange(0, 180, 90):
                # rotated = imutils.rotate_bound(img[minY:maxY,minX:maxX], angle)
                rotated = img#[minY-10:maxY,minX:maxX]
                cv2.imshow('final', rotated)
            # cv2.imshow('orig', orig)
            # cv2.imshow('mask', mask[minY-45:maxY+45,minX-70:maxX+70])
        except:
            pass

    if cv2.waitKey(1) == 27:
        break # esc


