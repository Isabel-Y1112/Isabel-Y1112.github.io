import pygame  
pygame.init()  

# Screen setup  
screen_width = 800  
screen_height = 600  
screen = pygame.display.set_mode((screen_width, screen_height))  
pygame.display.set_caption("JumpMan")  

# Colors  
WHITE = (255, 255, 255)  
BLUE = (0, 0, 255)  
RED = (255, 0, 0)  
GOLD = (255, 215, 0)  

# Player  
player_x = 50  
player_y = 500  
player_width = 40  
player_height = 60  
player_vel_y = 0  
jump = False  

# Platforms  
platforms = [  
    {"x": 0, "y": 550, "width": 800, "height": 50},  
    {"x": 200, "y": 450, "width": 100, "height": 20},  
    {"x": 400, "y": 350, "width": 100, "height": 20},  
    {"x": 600, "y": 250, "width": 100, "height": 20},  
]  

# Coins  
coins = [  
    {"x": 250, "y": 420, "collected": False},  
    {"x": 450, "y": 320, "collected": False},  
    {"x": 650, "y": 220, "collected": False},  
]  

# Game loop  
running = True  
clock = pygame.time.Clock()  
score = 0  
font = pygame.font.SysFont(None, 36)  

while running:  
    screen.fill(WHITE)  
    
    # Event handling  
    for event in pygame.event.get():  
        if event.type == pygame.QUIT:  
            running = False  
        if event.type == pygame.KEYDOWN:  
            if event.key == pygame.K_SPACE and not jump:  
                player_vel_y = -15  
                jump = True  

    # Player movement & gravity  
    player_y += player_vel_y  
    player_vel_y += 1  

    # Check platform collisions  
    for platform in platforms:  
        pygame.draw.rect(screen, BLUE, (platform["x"], platform["y"], platform["width"], platform["height"]))  
        
        if (player_x + player_width > platform["x"] and  
            player_x < platform["x"] + platform["width"] and  
            player_y + player_height > platform["y"] and  
            player_y + player_height < platform["y"] + 20 and  
            player_vel_y > 0):  
            player_y = platform["y"] - player_height  
            player_vel_y = 0  
            jump = False  

    # Draw player  
    pygame.draw.rect(screen, RED, (player_x, player_y, player_width, player_height))  

    # Coin collection  
    for coin in coins:  
        if not coin["collected"]:  
            pygame.draw.circle(screen, GOLD, (coin["x"], coin["y"]), 10)  
            if (player_x < coin["x"] + 10 and  
                player_x + player_width > coin["x"] - 10 and  
                player_y < coin["y"] + 10 and  
                player_y + player_height > coin["y"] - 10):  
                coin["collected"] = True  
                score += 1  

    # Display score  
    score_text = font.render(f"Score: {score}", True, (0, 0, 0))  
    screen.blit(score_text, (10, 10))  

    # Check if player falls  
    if player_y > screen_height:  
        running = False  

    pygame.display.update()  
    clock.tick(60)  

pygame.quit()  