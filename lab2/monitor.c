#include<stdio.h>
#include<string.h>
#include<pthread.h>
#include<stdlib.h>
#include<unistd.h>

pthread_t tid[2];
int counter;
pthread_mutex_t lock;
pthread_cond_t cond1;
int ready = 1;

void* producer(void *arg)
{ 
  printf("producer: started thread\n");

  while (1) {
    pthread_mutex_lock(&lock);
    if (ready == 1) {
      pthread_mutex_unlock(&lock);
      continue;
    }
    ready = 1;
    pthread_cond_signal(&cond1);
    printf("producer: sent message\n");
    pthread_mutex_unlock(&lock);
    sleep(2);
  }
  return NULL;
}

void* consumer(void *arg)
{
  printf("consumer: started thread\n");

  while (1) {
    pthread_mutex_lock(&lock);
    while (ready == 0)
    {
      pthread_cond_wait(&cond1, &lock);
    }
    printf("consumer: got message\n");
    ready = 0;
    pthread_mutex_unlock(&lock);
  }
  return NULL;
}


int main(void)
{
    int i = 0;
    int err;

    if (pthread_mutex_init(&lock, NULL) != 0)
    {
        printf("\n mutex init failed\n");
        return 1;
    }

    err = pthread_create(&(tid[0]), NULL, &producer, NULL);
    if (err != 0)
        printf("\ncan't create thread :[%s]", strerror(err));
    err = pthread_create(&(tid[1]), NULL, &consumer, NULL);
    if (err != 0)
        printf("\ncan't create thread :[%s]", strerror(err));

    pthread_join(tid[0], NULL);
    pthread_join(tid[1], NULL);
    pthread_mutex_destroy(&lock);

    return 0;
}