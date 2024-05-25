
#include "stm32f10x.h"
#include "stm32f10x_conf.h"
#include "stm32f10x_gpio.h"
#include "Delay.h"

void GPIO_Configuration(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;

    /* GPIOB clock enable */
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);

    GPIO_InitStructure.GPIO_Pin =  GPIO_Pin_13;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOC, &GPIO_InitStructure);
}

int main() {
    GPIO_Configuration();
    while(1) {
        GPIO_ResetBits(GPIOC, GPIO_Pin_13);
        Delay_ms(500);
        GPIO_SetBits(GPIOC, GPIO_Pin_13);
        Delay_ms(500);
    }
    return 0;
}