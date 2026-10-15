import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ExternalLinkService } from './external-link.service';
import { ExternalLinks } from './external-links';

const mockExternalLinkService = {
  externalLinksResource: new Proxy({}, { get: () => vi.fn() }),
};

describe('ExternalLinks', () => {
  let component: ExternalLinks;
  let fixture: ComponentFixture<ExternalLinks>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ExternalLinks],
      providers: [{ provide: ExternalLinkService, useValue: mockExternalLinkService }],
    }).compileComponents();

    fixture = TestBed.createComponent(ExternalLinks);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
