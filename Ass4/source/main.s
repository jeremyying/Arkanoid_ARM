/*	Cristhian Sotelo-Plaza
	30004060
	
	Zheyu Jeremy Ying
	30002931
	
	Zachary	Metz
	30001506
	
	CPSC359 WINTER 2018
	Assignment 4

*/


@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 	@ frame buffer information structure
	bl		initFbInfo

    bl init_SNES

    bl      mainMenu //calls the main menu




	@ stop
	haltLoop$:
		b	haltLoop$


@ Data section
.section .data

.align
.globl frameBufferInfo
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height



