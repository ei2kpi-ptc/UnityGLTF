using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;
namespace UnityGLTF
{
    public class AsyncCoroutineHelper : MonoBehaviour
    {
        public float BudgetPerFrameInSeconds = 0.01f;

        private float _timeout;

        public async Task YieldOnTimeout()
        {
            if (Time.realtimeSinceStartup > _timeout)
            {
                await Task.Delay(1);
            }
        }

        private void Start()
        {
            _timeout = Time.realtimeSinceStartup + BudgetPerFrameInSeconds;
        }

        private void Update()
        {
            _timeout = Time.realtimeSinceStartup + BudgetPerFrameInSeconds;
        }
    }
}
