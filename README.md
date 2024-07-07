# MS_sonification
A project to sonify mass spectrometry for proteomics data

Data sonification is not a new thing, however I find that some projects on data sonification take a simple vector or two and map them to MIDI values which are subsequently sent to a synthesiser.

I would like to synthesise sound which is more respectful towards the underlying data, in my case mass spectrometry (MS) data for proteomics experiments.

The Fourier theorem states that more complex waveforms can be built up of simpler periodic waveforms, and I noticed that the m/z values in MS data helpfully fall in the audible range (if converted to Hz).

Hence, this project takes individual spectra, and maps the m/z value to Hz and the intensity to amplitude. This generates a sine wave for every peak which are then overlaid to produce a tone for the spectrum.

I would like to extend this project so that an entire MS run can be sonified using the tones of the individual spectra.

## Things to try out
- Using a dedicated package to reverse fourier transform, this will probably be faster
- Formulate as a stand-alone program, like a synthesiser plugin almost
- Collect mass spectra from breathing into the mass spectrometer
- Generate tones from publically available metabolite spectra
