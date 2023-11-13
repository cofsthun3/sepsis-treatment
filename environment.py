import pandas as pd
import numpy as np
import ray
from ray.rllib.env import MultiAgentEnv

class SepsisEnv(MultiAgentEnv):
    def __init__(self, data):
        self.data = data
        self.current_step = 0
        self.current_episode = 0
        self.num_episodes = data['icustayid'].nunique()
        self.episodes = data['icustayid'].unique()
        self.action_space = 2 

    def reset(self):
        self.current_step = 0
        self.current_episode += 1
        return {"obs": self.data.loc[(self.data['icustayid'] == self.episodes[self.current_episode]) & (self.data['step'] == self.current_step), 'state']}

    def step(self, action_dict):
        current_row = self.data.loc[(self.data['icustayid'] == self.episodes[self.current_episode]) & (self.data['step'] == self.current_step)]
        reward = current_row['reward']
        self.current_step += 1

        if current_row['is_end'] != '1':
            next_state = {"obs": self.data.loc[(self.data['icustayid'] == self.episodes[self.current_episode]) & (self.data['step'] == self.current_step), 'state']}
            done = self.data.loc[(self.data['icustayid'] == self.episodes[self.current_episode]) & (self.data['step'] == self.current_step), 'is_end']
        else:
            next_state = None
            done = True
            self.reset()

        return next_state, reward, done, {}