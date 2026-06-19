import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ExternalLinks } from './external-links';
import { ExternalLinksService } from './external-links.service';

const mockExternalLinksService = { externalLinksResource: new Proxy({}, { get: () => vi.fn() }) };

describe('ExternalLinks', () => {
  let component: ExternalLinks;
  let fixture: ComponentFixture<ExternalLinks>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ExternalLinks],
      providers: [{ provide: ExternalLinksService, useValue: mockExternalLinksService }],
    }).compileComponents();

    fixture = TestBed.createComponent(ExternalLinks);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
