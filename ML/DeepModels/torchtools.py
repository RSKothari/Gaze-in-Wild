#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov  8 15:46:57 2019

@author: rakshit
"""
import torch
import numpy as np

class EarlyStopping:
    """Early stops the training if validation loss doesn't improve after a given patience."""
    # Modified by Rakshit Kothari
    def __init__(self,
                patience=7,
                verbose=False,
                delta=0,
                mode='min'):
        """
        Args:
            patience (int): How long to wait after last time validation loss improved.
                            Default: 7
            verbose (bool): If True, prints a message for each validation loss improvement.
                            Default: False
            delta (float): Minimum change in the monitored quantity to qualify as an improvement.
                            Default: 0
            fName (str): Name of the checkpoint file.
            path2save (str): Location of the checkpoint file.
        """
        self.patience = patience
        self.verbose = verbose
        self.counter = 0
        self.best_score = None
        self.early_stop = False
        self.update_flag = False
        self.best_model = dict()

        if mode is 'min':
            self.val_loss_min = np.Inf
        elif mode is 'max':
            self.val_loss_min = -np.Inf
        else:
            print('Undefined mode. Exit.')
        self.delta = delta
        self.mode = mode

    def __call__(self,eps, val_loss, model):
        if self.mode == 'min':
            score = -val_loss
        else:
            score = val_loss

        if self.best_score is None:
            self.best_score = score
            self.save_checkpoint(eps, val_loss, model)

        elif score < self.best_score + self.delta:
            self.update_flag = False
            self.counter += 1
            print('EarlyStopping counter: {} out of {}'.format(self.counter, self.patience))
            if self.counter >= self.patience:
                self.early_stop = True
        else:
            self.update_flag = True
            self.best_score = score
            self.save_checkpoint(eps, val_loss, model)
            self.val_loss_min = score.item()
            self.counter = 0

    def save_checkpoint(self, eps, val_loss, model_dict):
        '''Saves model when validation loss decrease.'''
        if self.verbose and self.mode is 'min':
            print('Validation metric decreased ({:.6f} --> {:.6f}).  Saving model ...'.format(self.val_loss_min, val_loss.item()))
        elif self.verbose and self.mode is 'max':
            print('Validation metric increased ({:.6f} --> {:.6f}).  Saving model ...'.format(self.val_loss_min, val_loss.item()))
        self.best_model['net_params'] = model_dict
        self.best_model['eps'] = eps
        self.best_model['metric'] = val_loss

def verify_weights(best_model_dict, net_dict):
    for key in net_dict.keys():
        val = torch.sum(net_dict[key] - best_model_dict[key])
        if val != 0:
            print('WTF! Values do not match')
        else:
            print('Match')