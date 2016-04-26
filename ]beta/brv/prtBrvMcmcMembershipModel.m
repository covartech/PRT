classdef prtBrvMcmcMembershipModel  < prtBrvMembershipModel





    methods (Abstract)

        model = draw(self);
        y = logPdfFromDraw(self, model, x);
        y = pdfFromDraw(self, model, x);
    end
end
