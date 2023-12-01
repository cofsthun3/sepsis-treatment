from environment import SepsisEnv
import ray
from ray import tune
from ray.rllib.algorithms.ddpg import ddpg# DDPGTrainer


def run_agent(env):
    config = {
        "env_config": env,
        "framework": "torch",
        "num_workers": 1,
        "num_gpus": 0,
        "gamma": 0.99,
        "actor_hiddens": [32] * 3,
        "critic_hiddens": [32] * 3,
        "buffer_size": 350000,
        "learning_starts": 350000 // 32,
        "tau": 0.01,
        "train_batch_size": 32,
        "actor_lr": 3e-3,
        "critic_lr": 3e-5,
    }

    ray.init(ignore_reinit_error=True)

    results = tune.run(
        ddpg,#DDPGTrainer,
        config=config,
        stop={"training_iteration": 20000},
        checkpoint_freq=5000,
    )

    best_trial = results.get_best_trial("episode_reward_mean", mode="max")
    print("Best trial mean reward:", best_trial.last_result["episode_reward_mean"])

    ray.shutdown()
