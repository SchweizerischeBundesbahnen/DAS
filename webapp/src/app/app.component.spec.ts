import { TestBed } from '@angular/core/testing';
import { AppComponent } from './app.component';
import { AuthService } from "./auth.service";
import { MqService } from "./mq.service";

const mockAuth: Partial<AuthService> = {};
const mockMq: Partial<MqService> = {};

describe('AppComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppComponent],
      providers: [
        {provide: AuthService, useValue: mockAuth},
        {provide: MqService, useValue: mockMq}
      ]
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });
});
