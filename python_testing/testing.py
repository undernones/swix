
from __future__ import division
from pylab import *
from sklearn import datasets
from sklearn import svm
#import cv2

def svmTest():
    def sk_learn():
        data = datasets.load_digits()
        N_test = int(1050)

        x_train = data['data'][:-N_test]
        y_train = data['target'][:-N_test]

        x_test = data['data'][-N_test:]
        y_test = data['target'][-N_test:]

        np.savetxt("csvs/x_train.csv", x_train, delimiter=",")#@asdjkk
        np.savetxt("csvs/y_train.csv", y_train, delimiter=",", newline=",")
        np.savetxt("csvs/x_test.csv", x_test, delimiter=",")
        np.savetxt("csvs/y_test.csv", y_test, delimiter=",", newline=",")

        ml = svm.LinearSVC()
        ml = ml.fit(x_train, y_train)
        yhat_test = ml.predict(x_test)

        print argwhere(abs(yhat_test - y_test) < 0.5).shape[0] / y_test.shape[0]
    data = datasets.load_digits()
    N_test = int(1050)
    x_train = data['data'][:-N_test]
    y_train = data['target'][:-N_test]

    x_test = data['data'][-N_test:]
    y_test = data['target'][-N_test:]

    x_train = asarray(x_train, dtype=float32)
    y_train = asarray(y_train, dtype=float32)
    x_test = asarray(x_test, dtype=float32)

    params = dict(kernel_type=cv2.SVM_SIGMOID, svm_type=cv2.SVM_C_SVC)
    cv_svm = cv2.SVM()

    cv_svm.train(x_train, y_train, params=params)
    yhat = cv_svm.predict_all(x_test)

    print "Percent correct:", argwhere(abs(yhat.flat[:] - y_test) < 0.5).shape[0] / yhat.shape[0]

def pinvTest():
    M = 3
    N = 4
    x = arange(M*N).reshape(M,N)

    y = pinv(x)

def kronTest():
    A = array([1, 2, 3, 4, 5, 6]).reshape(2, 3)
    B = array([3, 2, 5, 0, 1, 2]).reshape(3,2)
    print kron(A, B)

#def convolveTest():
from scipy.signal import fftconvolve

x = arange(10)
k = ones(4) / 4
y = fftconvolve(x, k, mode='same')

print np.around(y, decimals=3)
